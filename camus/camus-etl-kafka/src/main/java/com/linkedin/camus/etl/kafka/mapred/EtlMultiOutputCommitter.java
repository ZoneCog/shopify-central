package com.linkedin.camus.etl.kafka.mapred;

import com.linkedin.camus.etl.RecordWriterProvider;
import com.linkedin.camus.etl.kafka.common.EtlCounts;
import com.linkedin.camus.etl.kafka.common.EtlKey;
import com.linkedin.camus.shopify.CamusLogger;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.FileUtil;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.SequenceFile;
import org.apache.hadoop.mapreduce.JobContext;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.hadoop.mapreduce.lib.output.FileOutputCommitter;
import org.apache.log4j.Logger;
import org.codehaus.jackson.map.ObjectMapper;

import java.io.*;
import java.lang.reflect.Constructor;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class EtlMultiOutputCommitter extends FileOutputCommitter {
  private Pattern workingFileMetadataPattern;

  private HashMap<String, EtlCounts> counts = new HashMap<String, EtlCounts>();
  private HashMap<String, EtlKey> offsets = new HashMap<String, EtlKey>();
  private HashMap<String, Long> eventCounts = new HashMap<String, Long>();
  private HashSet<String> pathsWritten = new HashSet<String>();
  private HashSet<Path> filesWritten = new HashSet<Path>();
  private Path outputPath;

  private TaskAttemptContext context;
  private final RecordWriterProvider recordWriterProvider;
  private CamusLogger log;
  private int MAX_GCS_UPLOAD_RETRIES = 3;

  public static enum FILE_COMMITTER {
    MOVE_SUCCESS,
    UPLOAD_SUCCESS,
    UPLOAD_FAILURE
  };

  private void mkdirs(FileSystem fs, Path path) throws IOException {
    if (!fs.exists(path.getParent())) {
      mkdirs(fs, path.getParent());
    }
    fs.mkdirs(path);
  }

  public void addCounts(EtlKey key) throws IOException {
    String workingFileName = EtlMultiOutputFormat.getWorkingFileName(context, key);
    if (!counts.containsKey(workingFileName))
      counts.put(workingFileName,
          new EtlCounts(key.getTopic(), EtlMultiOutputFormat.getMonitorTimeGranularityMs(context)));
    counts.get(workingFileName).incrementMonitorCount(key);
    addOffset(key);
  }

  public void addOffset(EtlKey key) {
    String topicPart = key.getTopic() + "-" + key.getLeaderId() + "-" + key.getPartition();
    EtlKey offsetKey = new EtlKey(key);

    if (offsets.containsKey(topicPart)) {
      long totalSize = offsets.get(topicPart).getTotalMessageSize() + key.getMessageSize();
      long avgSize = totalSize / (eventCounts.get(topicPart) + 1);
      offsetKey.setMessageSize(avgSize);
      offsetKey.setTotalMessageSize(totalSize);
    } else {
      eventCounts.put(topicPart, 0l);
    }
    eventCounts.put(topicPart, eventCounts.get(topicPart) + 1);
    offsets.put(topicPart, offsetKey);
  }

  public EtlMultiOutputCommitter(Path outputPath, TaskAttemptContext context, Logger log) throws IOException {
    super(outputPath, context);
    this.outputPath = outputPath;
    this.context = context;
    try {
      //recordWriterProvider = EtlMultiOutputFormat.getRecordWriterProviderClass(context).newInstance();
      Class<RecordWriterProvider> rwp = EtlMultiOutputFormat.getRecordWriterProviderClass(context);
      Constructor<RecordWriterProvider> crwp = rwp.getConstructor(TaskAttemptContext.class);
      recordWriterProvider = crwp.newInstance(context);
    } catch (Exception e) {
      throw new IllegalStateException(e);
    }
    workingFileMetadataPattern = Pattern.compile(
        "data\\.([^\\.]+)\\.([\\d_]+)\\.(\\d+)\\.([^\\.]+)-m-\\d+" + recordWriterProvider.getFilenameExtension());
    this.log = new CamusLogger(log);
  }

  @Override
  public void commitTask(TaskAttemptContext context) throws IOException {

    ArrayList<Map<String, Object>> allCountObject = new ArrayList<Map<String, Object>>();
    FileSystem fs = FileSystem.get(context.getConfiguration());
    if (EtlMultiOutputFormat.isRunMoveData(context)) {
      Path workPath = super.getWorkPath();
      log.info("work path: " + workPath);
      Path baseOutDir = EtlMultiOutputFormat.getDestinationPath(context);
      log.info("Destination base path: " + baseOutDir);
      for (FileStatus f : fs.listStatus(workPath)) {
        String file = f.getPath().getName();
        log.info("work file: " + file);
        if (file.startsWith("data")) {
          String workingFileName = file.substring(0, file.lastIndexOf("-m"));
          EtlCounts count = counts.get(workingFileName);
          count.setEndTime(System.currentTimeMillis());

          String partitionedFile =
              getPartitionedPath(context, file, count.getEventCount(), count.getLastKey().getOffset());

          Path dest = new Path(baseOutDir, partitionedFile);

          Path parentDestPath = dest.getParent();
          if (!fs.exists(parentDestPath)) {
            mkdirs(fs, parentDestPath);
          }

          commitFile(context, f.getPath(), dest);
          log.info("Moved file from: " + f.getPath() + " to: " + dest);
          context.getCounter(FILE_COMMITTER.MOVE_SUCCESS).increment(1);

          // record the fact that we committed data to a path
          pathsWritten.add(parentDestPath.toString());

          filesWritten.add(dest);

          // upload to gcs
          if (EtlMultiOutputFormat.upoadToGCS(context)) {
            uploadToGcs(context, fs, partitionedFile, dest);
          }

          if (EtlMultiOutputFormat.isRunTrackingPost(context)) {
            count.writeCountsToMap(allCountObject, fs, new Path(workPath, EtlMultiOutputFormat.COUNTS_PREFIX + "."
                + dest.getName().replace(recordWriterProvider.getFilenameExtension(), "")));
          }
        }
      }

      if (EtlMultiOutputFormat.isRunTrackingPost(context)) {
        Path tempPath = new Path(workPath, "counts." + context.getConfiguration().get("mapred.task.id"));
        OutputStream outputStream = new BufferedOutputStream(fs.create(tempPath));
        ObjectMapper mapper = new ObjectMapper();
        log.info("Writing counts to : " + tempPath.toString());
        long time = System.currentTimeMillis();
        mapper.writeValue(outputStream, allCountObject);
        log.debug("Time taken : " + (System.currentTimeMillis() - time) / 1000);
      }
    } else {
      log.info("Not moving run data.");
    }

    SequenceFile.Writer offsetWriter = SequenceFile.createWriter(fs, context.getConfiguration(),
        new Path(super.getWorkPath(),
            EtlMultiOutputFormat.getUniqueFile(context, EtlMultiOutputFormat.OFFSET_PREFIX, "")),
        EtlKey.class, NullWritable.class);
    for (String s : offsets.keySet()) {
      log.info("Avg record size for " + offsets.get(s).getTopic() + ":" + offsets.get(s).getPartition() + " = "
          + offsets.get(s).getMessageSize());
      offsetWriter.append(offsets.get(s), NullWritable.get());
    }
    offsetWriter.close();

    // write a list of files that were written
    ArrayList<String> pathsWrittenList = new ArrayList(pathsWritten);
    Collections.sort(pathsWrittenList);
    OutputStream os = fs.create(new Path(super.getWorkPath(),
            EtlMultiOutputFormat.getUniqueFile(context, EtlMultiOutputFormat.PATHS_WRITTEN_PREFIX, "")));
    BufferedWriter br = new BufferedWriter( new OutputStreamWriter( os, "UTF-8" ) );
    for (String writtenToPath : pathsWrittenList) {
      br.write(writtenToPath);
      br.write("\n");
    }
    br.close();

    super.commitTask(context);
  }

  private void uploadToGcs(TaskAttemptContext context, FileSystem fs, String partitionedFile, Path dest) {
    for (int retries = 0; retries <= MAX_GCS_UPLOAD_RETRIES; retries++) {
      try {
        Configuration googleConfig = new Configuration(fs.getConf());
        googleConfig.set("fs.default.name", EtlMultiOutputFormat.getGCSPrefix(context));
        // FileSystem.newInstace could throw IOException which is why I'm keeping
        // all of this setup inside the try block despite being potentially wasteful.
        FileSystem googleFs = FileSystem.newInstance(googleConfig);
        Path baseOutDirGCS = EtlMultiOutputFormat.getDestinationPathGCS(context);
        Path gcsDest = new Path(baseOutDirGCS, partitionedFile);
        // copy the file that we've committed to gcs
        uploadFile(fs, dest, googleFs, gcsDest, googleConfig);
        return;
      } catch (Exception e) {
        if (retries < MAX_GCS_UPLOAD_RETRIES) {
          log.error(String.format("Failed uploading %s, will re-try (retries so far: %d)", dest, retries));
        } else {
          log.error(String.format("Failed to upload %s", dest));
          log.error(e.toString());
          context.getCounter(FILE_COMMITTER.UPLOAD_FAILURE).increment(1);
        }
      }
    }
  }

  protected void commitFile(JobContext job, Path source, Path target) throws IOException {
    log.info(String.format("Moving %s to %s", source, target));
    if (!FileSystem.get(job.getConfiguration()).rename(source, target)) {
      log.error(String.format("Failed to move from %s to %s", source, target));
      throw new IOException(String.format("Failed to move from %s to %s", source, target));
    }
  }

  protected void uploadFile(FileSystem sourceFs, Path source,  FileSystem targetFS, Path target, Configuration conf) throws IOException {
    log.info(String.format("Uploading %s to %s", source, target));
    if (!FileUtil.copy(sourceFs, source, targetFS, target, false, false, conf)) {
        throw new IOException(String.format("Failed to upload from %s to %s", source, target));
    }
    else {
      context.getCounter(FILE_COMMITTER.UPLOAD_SUCCESS).increment(1);
    }
  }

  public String getPartitionedPath(JobContext context, String file, int count, long offset) throws IOException {
    Matcher m = workingFileMetadataPattern.matcher(file);
    if (!m.find()) {
      throw new IOException("Could not extract metadata from working filename '" + file + "'");
    }
    String topic = m.group(1);
    String leaderId = m.group(2);
    String partition = m.group(3);
    String encodedPartition = m.group(4);

    String partitionedPath =
        EtlMultiOutputFormat.getPartitioner(context, topic).generatePartitionedPath(context, topic, encodedPartition);

    partitionedPath += "/" + EtlMultiOutputFormat.getPartitioner(context, topic).generateFileName(context, topic,
        leaderId, Integer.parseInt(partition), count, offset, encodedPartition);

    return partitionedPath + recordWriterProvider.getFilenameExtension();
  }

  public void cleanupJob(JobContext context) throws IOException {
    Path tempPath = new Path(this.outputPath, "_temporary");
    log.info("Cleaning up job. Preserving directory for analysis/salvaging: " + tempPath.toString());
  }

  public void abortTask(TaskAttemptContext context) throws IOException {
    Path taskAttemptPath = this.getTaskAttemptPath(context);
    log.info("Aborting task. Preserving directory for analysis/salvaging: " + taskAttemptPath.toString());
    log.info("Attempting to rollback committed files");

    FileSystem fs = taskAttemptPath.getFileSystem(context.getConfiguration());
    for (Path file : filesWritten) {
      log.info("Rolling back committed file: " + file.toString());
      if (!fs.delete(file, false)) {
        throw new IOException(String.format("Failed to rollback file: %s ", file.toString()));
      }

      // rollback from GCS
      if (EtlMultiOutputFormat.upoadToGCS(context)) {
        Configuration googleConfig = new Configuration(fs.getConf());
        googleConfig.set("fs.default.name", EtlMultiOutputFormat.getGCSPrefix(context));
        FileSystem googleFs = FileSystem.newInstance(googleConfig);
        Path baseOutDirGCS = EtlMultiOutputFormat.getDestinationPathGCS(context);
        Path gcsDest = new Path(baseOutDirGCS, file);
        // remove the file that we've committed to gcs
        log.info(String.format("Deleting %s from GCS", gcsDest));

        if (!googleFs.delete(gcsDest, false)) {
          throw new IOException(String.format("Failed deleting file from GCS: %s", gcsDest.toString()));
        }
      }
    }
  }
}
