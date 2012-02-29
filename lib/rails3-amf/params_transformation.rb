module Rails3AMF
  class ParamsTransformation
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