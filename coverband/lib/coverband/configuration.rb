module Coverband
  class Configuration
    attr_accessor :redis, :coverage_baseline, :root_paths, :root, :ignore, :percentage, :verbose, :reporter, :stats, :logger, :startup_delay, :baseline_file, :reporter
    
    def initialize
      @root = Dir.pwd
      @redis = nil
      @stats = nil
      @coverage_baseline = {}
      @baseline_file = './tmp/coverband_baseline.json'
      @root_paths = []
      @ignore = []
      @percentage = 0.0
      @verbose = false
      @reporter = 'scov'
      @logger = Logger.new(STDOUT)
      @startup_delay = 0
      @reporter = nil
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

  end
end
