class SkyDB
  class Event
    ##########################################################################
    #
    # Constructor
    #
    ##########################################################################

    # Initializes the event.
    def initialize(options={})
      self.timestamp = options[:timestamp] || DateTime.now
      self.data = options[:data] || {}
    end
    

    ##########################################################################
    #
    # Attributes
    #
    ##########################################################################

    # The moment the event occurred.
    attr_accessor :timestamp

    # The data associated with the event.
    attr_accessor :data

    # The timestamp as ISO8601 formatted string with fractional seconds.
    def formatted_timestamp()
      return SkyDB.format_timestamp(timestamp)
    end


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################

    ####################################
    # Encoding
    ####################################

    # Encodes the event into a hash.
    def to_hash(*a)
      {
        'timestamp' => formatted_timestamp,
        'data' => data
      }
    end

    # Decodes a hash into a event.
    def from_hash(hash, *a)
      self.timestamp = !hash.nil? ? parse_timestamp(hash['timestamp']) : Time.now.utc.to_datetime()
      self.data = !hash.nil? ? hash['data'] : {}
      return self
    end

    def as_json(*a); return to_hash(*a); end
    def to_json(*a); return as_json(*a).to_json; end

    ####################################
    # Timestamp
    ####################################
    
    # Parses an ISO8601 date string with fractional seconds.
    #
    # @param [String] str  The date string to parse.
    #
    # @return [DateTime]  The parsed date.
    def parse_timestamp(str)
      # Try to parse with fractional seconds first and then fallback to
      # a regular ISO8601 format.
      begin
        return DateTime.strptime(str, '%Y-%m-%dT%H:%M:%S.%NZ')
      rescue ArgumentError
        return DateTime.strptime(str, '%Y-%m-%dT%H:%M:%SZ')
      end
    end
  end
end