package org.wikimedia.analytics.refinery.job

import com.linkedin.camus.etl.kafka.common.EtlKey
import org.apache.hadoop.fs._
import org.apache.hadoop.io.{NullWritable, SequenceFile, Writable, WritableComparable}

/**
  * This is a modified version of the original class found in https://github.com/wikimedia/analytics-refinery-source
  * whose original author is Joseph Allemandou <joal@wikimedia.org>
  */
class CamusStatusReader(fs: FileSystem) {

  /**
   * Reads EtlKeys from a sequence file
   * @param path the Path of the sequence file
   * @return the read EtlKey sequence
   */
  def readEtlKeys(path: Path): Seq[EtlKey] = {
    val reader = new SequenceFile.Reader(fs, path, fs.getConf)
    val key: WritableComparable[_] = reader.getKeyClass.newInstance.asInstanceOf[WritableComparable[_]]
    val value: Writable = NullWritable.get
    // Would have liked to be fully functionnal ...
    // But nexct function doesn't really allow
    var keys = Seq.empty[EtlKey]
    while (reader.next(key, value)) {
        keys :+= new EtlKey(key.asInstanceOf[EtlKey])
    }
    reader.close
    keys
  }

  /**
   * Reads EtlKeys from multiple sequence files, grouping results in a sequence.
   * @param paths the sequence of Paths of the sequence files
   * @return the read EtlKey sequence
   */
  def readEtlKeys(paths: Seq[Path]): Seq[EtlKey] = paths.flatMap(this.readEtlKeys(_))

  /**
   * Private class to easily filter when listing files in folders
   * @param regexp
   */
  private class RegexpPathFilter(regexp: String) extends PathFilter {
    override def accept(path: Path): Boolean = path.getName matches regexp
  }

  /**
   * Finds offsets files in a camus-run folder.
   * @param path the path to scan for files
   * @return a list of offset-m-XXXXX paths
   */
  def offsetsFiles(path: Path): Seq[Path] = fs.listStatus(path, new RegexpPathFilter("offsets-m-[0-9]{5}")).map(_.getPath)

  /**
   * Finds previous offsets files in a camus-run folder.
   * @param path the path to scan for files
   * @return a list of offsetprevious paths (should contain only 1 element)
   */
  def previousOffsetsFiles(path: Path): Seq[Path] = fs.listStatus(path, new RegexpPathFilter("offsets-previous")).map(_.getPath)

  def topicsAndOldestTimes(keys: Seq[EtlKey]): Map[String, Long] = {
    keys.foldLeft (Map.empty[String, Long]) ((map, k) => {
        if ((! map.contains(k.getTopic)) || (map.get(k.getTopic).get > k.getTime))
          map + (k.getTopic -> k.getTime)
        else
          map
      })
  }

  /**
   * Finds the most recent run in a camus-history folder
   * @return the most recent run path
   */
  def mostRecentRun(path: Path): Path = {
    mostRecentRuns(path).head
  }

  /**
   * Finds the most recent runs in a camus-history folder
   * @return a list of directories for the most recent runs
   */
  def mostRecentRuns(path: Path, count: Int = 1): List[Path] = {
    // Filter folders with format YYYY-MM-DD-HH-MM-SS
    // Sort folders by name DESC
    val executions = fs.listStatus(path, new RegexpPathFilter("[0-9]{4}(-[0-9]{2}){5}")).map(_.getPath)
      .sortWith((f1, f2) => f1.getName().compareTo(f2.getName()) > 0)
    if (executions.length >= 0)
      executions.take(count).toList
    else
      throw new IllegalArgumentException("Given Path is doesn't contain camus-run folders.")
  }

}
