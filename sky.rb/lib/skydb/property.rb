class SkyDB
  class Property
    ##########################################################################
    #
    # Constructor
    #
    ##########################################################################

    # Initializes the property.
    def initialize(options={})
      self.id = options[:id].to_i
      self.name = options[:name]
      self.transient = options[:transient] || false
      self.data_type = options[:data_type] || "string"
    end
    

    ##########################################################################
    #
    # Attributes
    #
    ##########################################################################

    # The property identifier.
    attr_accessor :id

    # The name of the property.
    attr_accessor :name

    # A flag stating if the value of the property only exists for a single moment.
    attr_accessor :transient

    # The property's data type.
    attr_accessor :data_type


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################

    ####################################
    # Encoding
    ####################################

    # Encodes the property into a hash.
    def to_hash(*a)
      hash = {
        'name' => name,
        'transient' => transient,
        'dataType' => data_type,
      }
      hash['id'] = id if id < 0 || id > 0
      return hash
    end

    # Decodes a hash into a property.
    def from_hash(hash, *a)
      self.id = !hash.nil? ? hash['id'].to_i : 0
      self.name = !hash.nil? ? hash['name'] : ''
      self.transient = !hash.nil? ? hash['transient'] : false
      self.data_type = !hash.nil? ? hash['dataType'] : ''
      return self
    end

    def as_json(*a); return to_hash(*a); end
    def to_json(*a); return as_json(*a).to_json; end
  end
end