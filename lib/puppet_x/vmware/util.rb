module PuppetX
  module VMware
    module Util
      def self.camelize(snake_case, first_letter = :upper)
        case first_letter
        when :upper
          snake_case.to_s.
              gsub(/\/(.?)/){ "::" + $1.upcase }.
              gsub(/(^|_)(.)/){ $2.upcase }
        when :lower
          snake_case.to_s[0].chr + camelize(snake_case)[1..-1]
        end
      end

      def self.snakeize(camel_case)
        camel_case.to_s.
            sub(/^[A-Z]+/){|s| s.downcase}.
            gsub(/[A-Z]+/){|s| '_' + s.downcase}
      end

      def self.nested_value(hash, keys, default=nil)
        value = hash.dup
        keys.each_with_index do |item, index|
          # handle Hash or RbVmomi::BasicTypes::ObjectWithProperties
          unless (value.respond_to? :[]) && value[item]
            default = yield hash, keys, index if block_given?
            return default
          end
          value = value[item]
        end
        value
      end

      def self.nested_value_set(hash, keys, value)
        fail "'hash' is not a hash: '#{hash.inspect}'" unless hash.is_a? Hash
        fail "'keys' is not an array: '#{keys.inspect}'" unless keys.is_a? Array
        fail "'keys' array is empty" if keys.empty?

        node = hash
        keys = keys.dup.map{|el| el.to_sym}
        Puppet.debug "setting value at #{keys.inspect}"
        
        # Note: if keys has only one element, keys[0..-2] is [],
        # so this code will insert value at top level of hash...
        # not particularly useful, but not obviously an error

        keys[0..-2].each_with_index do |key, index|
          if not node.include? key
            Puppet.debug "adding empty hash at #{keys[0..index].inspect}"
            node = node[key] = {}
          elsif node[key].is_a? Hash
            node = node[key]
          else
            Puppet.debug "node is not a hash: '#{node[key].inspect}'"
            fail "node at #{keys[0..index].inspect} is not a hash"
          end
        end

        node[keys[-1]] = value
      end

    end
  end
end
