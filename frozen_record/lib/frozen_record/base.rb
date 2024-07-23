require 'set'
require 'active_support/descendants_tracker'

module FrozenRecord
  class Base
    extend ActiveSupport::DescendantsTracker
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::AttributeMethods
    include ActiveModel::Serializers::JSON

    if defined? ActiveModel::Serializers::Xml
      include ActiveModel::Serializers::Xml
    end

    FIND_BY_PATTERN = /\Afind_by_(\w+)(!?)/
    FALSY_VALUES = [false, nil, 0, ''].to_set

    class_attribute :base_path

    class_attribute :primary_key
    self.primary_key = :id

    class_attribute :auto_reloading

    attribute_method_suffix '?'

    class ThreadSafeStorage

      def initialize(key)
        @thread_key = "#{ self.object_id }-#{ key }"
      end

      def [](key)
        Thread.current[@thread_key] ||= {}
        Thread.current[@thread_key][key]
      end

      def []=(key, value)
        Thread.current[@thread_key] ||= {}
        Thread.current[@thread_key][key] = value
      end

    end

    class << self
      attr_accessor :abstract_class

      def abstract_class?
        defined?(@abstract_class) && @abstract_class
      end

      def current_scope
        store[:scope] ||= Scope.new(self)
      end
      alias_method :all, :current_scope

      def current_scope=(scope)
        store[:scope] = scope
      end

      delegate :find, :find_by_id, :find_by, :find_by!, :where, :first, :first!, :last, :last!, :pluck, :ids, :order, :limit, :offset,
               :minimum, :maximum, :average, :sum, :count, to: :current_scope

      def file_path
        raise ArgumentError, "You must define `#{name}.base_path`" unless base_path
        File.join(base_path, "#{name.underscore.pluralize}.yml")
      end

      def respond_to_missing?(name, *)
        if name.to_s =~ FIND_BY_PATTERN
          load_records # ensure attribute methods are defined
          return true if $1.split('_and_').all? { |attr| instance_method_already_implemented?(attr) }
        end
      end

      def eager_load!
        if auto_reloading
          raise RuntimeError, "There is no point eager loading a FrozenRecord if auto_reloading is enabled!"
        end

        return if abstract_class?

        load_records
      end

      def load_records
        if auto_reloading && file_changed?
          @records = nil
          undefine_attribute_methods
        end

        @records ||= begin
          yml_erb_data = File.read(file_path)
          yml_data = ERB.new(yml_erb_data).result

          records = YAML.load(yml_data) || []
          define_attribute_methods(list_attributes(records))
          records.map(&method(:new)).freeze
        end
      end

      private

      def file_changed?
        last_mtime = @file_mtime
        @file_mtime = File.mtime(file_path)
        last_mtime != @file_mtime
      end

      def store
        @store ||= ThreadSafeStorage.new(name)
      end

      def method_missing(name, *args)
        if name.to_s =~ FIND_BY_PATTERN
          return dynamic_match($1, args, $2.present?)
        end
        super
      end

      def dynamic_match(expression, values, bang)
        results = where(expression.split('_and_').zip(values))
        bang ? results.first! : results.first
      end

      def list_attributes(records)
        attributes = Set.new
        records.each do |record|
          record.keys.each do |key|
            attributes.add(key.to_s)
          end
        end
        attributes.to_a
      end

    end

    attr_reader :attributes

    def initialize(attrs = {})
      @attributes = attrs.stringify_keys
    end

    def id
      self[primary_key]
    end

    def [](attr)
      @attributes[attr.to_s]
    end
    alias_method :attribute, :[]

    def ==(other)
      super || other.is_a?(self.class) && other.id == id
    end

    def persisted?
      true
    end

    def to_key
      [id]
    end

    private

    def attribute?(attribute_name)
      FALSY_VALUES.exclude?(self[attribute_name]) && self[attribute_name].present?
    end

  end
end
