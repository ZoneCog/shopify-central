package com.linkedin.camus.etl.kafka.reporter;

import com.timgroup.statsd.StatsDClient;
import com.timgroup.statsd.NonBlockingStatsDClient;
import java.util.Map;
import java.io.IOException;
import java.util.Properties;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Counter;
import org.apache.hadoop.mapreduce.Counters;
import org.apache.hadoop.mapreduce.CounterGroup;
import org.apache.hadoop.util.ToolRunner;

import com.linkedin.camus.etl.kafka.reporter.TimeReporter;


public class StatsdReporter extends TimeReporter {

  public static final String STATSD_ENABLED = "statsd.enabled";
  public static final String STATSD_HOST = "statsd.host";
  public static final String STATSD_PORT = "statsd.port";

  private static boolean statsdEnabled;
  private static StatsDClient statsd;

  public void report(Job job, Map<String, Long> timingMap) throws IOException {
    super.report(job, timingMap);
    submitCountersToStatsd(job);
    submitTimingToStatsd(job, timingMap);
  }

  private static StatsDClient getClient(Configuration conf) {
    return new NonBlockingStatsDClient("Camus", getStatsdHost(conf), getStatsdPort(conf),
            new String[] { "camus:counters" });
  }

  private static StatsDClient getClient(Properties props) {
    return new NonBlockingStatsDClient("Camus", props.getProperty(STATSD_HOST),
            Integer.parseInt(props.getProperty(STATSD_PORT, "8125")),
            new String[] { "camus:counters" });
  }

  private void submitCountersToStatsd(Job job) throws IOException {
    Counters counters = job.getCounters();
    Configuration conf = job.getConfiguration();
    if (getStatsdEnabled(conf)) {
      StatsDClient statsd = getClient(conf);
      for (CounterGroup counterGroup : counters) {
        for (Counter counter : counterGroup) {
          statsd.gauge(counterGroup.getDisplayName() + "." + counter.getDisplayName(), counter.getValue());
        }
      }
    }
  }

  private void submitTimingToStatsd(Job job, Map<String, Long> timingMap) throws IOException {
    Configuration conf = job.getConfiguration();
    if (getStatsdEnabled(conf)) {
      StatsDClient statsd = getClient(conf);
      String[] times = new String[]{"pre-setup", "getSplits", "hadoop", "commit", "total"};
      for (String key : times) {
        statsd.gauge("run-time" + "." + key, timingMap.get(key));
      }
    }
  }

  public static Boolean getStatsdEnabled(Configuration conf) {
    return conf.getBoolean(STATSD_ENABLED, false);
  }

  public static String getStatsdHost(Configuration conf) {
    return conf.get(STATSD_HOST, "localhost");
  }

  public static int getStatsdPort(Configuration conf) {
    return conf.getInt(STATSD_PORT, 8125);
  }

  public static void gauge(Configuration conf, String metric, Long value, String... tags) {
    if (conf.getBoolean(STATSD_ENABLED, false)) {
      StatsDClient statsd = getClient(conf);
      statsd.gauge(metric, value, tags);
    }
  }
  public static void gauge(Properties props, String metric, Long value, String... tags) {
    if (!props.getProperty(STATSD_ENABLED, "false").equals("false")) {
      StatsDClient statsd = getClient(props);
      statsd.gauge(metric, value, tags);
    }
  }
}
