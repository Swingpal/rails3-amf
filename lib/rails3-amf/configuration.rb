module Rails3AMF
  class Configuration
    class << self
      def populate config
        @config = config
      end

      def reset
        Rails3AMF::Configuration.new
      end

      def method_missing name, *args
        @config.send(name, *args)
      end
    end

    def initialize
      @data = {
        :gateway_path => "/amf",
        :auto_class_mapping => false
      }
      @param_mappings = {}

      # Make config available globally
      Rails3AMF::Configuration.populate self
    end

    def class_mapping &block
      RocketAMF::ClassMapper.define(&block)
    end

    def map_params options
      @param_mappings[options[:controller]+"#"+options[:action]] = underscore_hash_keys(options[:params])
    end

    def mapped_params controller, action, arguments
      mapped = {}
      if mapping = @param_mappings[controller+"#"+action]
        arguments.each_with_index {|arg, i| mapped[mapping[i]] = arg}
      end
      mapped
    end

    def method_missing name, *args
      if name.to_s =~ /(.*)=$/
        @data[$1.to_sym] = args.first
      else
        @data[name]
      end
    end
    
    def underscore_hash_keys(hash)
      case hash
        when Array
          hash.map { |v| underscore_hash_keys(v) }
        when Hash
          Hash[hash.map{|k, v| [underscore_key(k), underscore_hash_keys(v)]}]
        else
          hash
      end
    end

    def underscore_key(k)
      k.to_s.underscore.to_sym unless k.is_a? Integer
    end    
  end
end