require 'pathname'

module Puppet::Modules
  module VCenter
    module TypeBase

      def TypeBase.get_immediate_parent(path)
        pathname = Pathname.new(path)
        if !pathname.root?
          pathname.parent
        else
          nil
        end
      end

      def TypeBase.get_validate_path_block
        lambda do |path|
          if path.empty?
            raise ArgumentError, "path cannot be empty."
          else
            if not path.start_with?('/')
              raise ArgumentError, "path must start with a '/'."
            elsif path.size == 1
              raise ArgumentError, "path must specify more than '/'."
            end
            super
          end
        end
      end

      def TypeBase.get_munge_path_block
        lambda do |path|
          if path.end_with?('/')
            super
          else
            path + '/'
          end
        end
      end

      def TypeBase.get_validate_connection_block
        lambda do |value|
          if /^[^:|^@]+:[^:|^@]+@[^:|^@]+$/.match(value)
            super
          else
            raise ArgumentError, "Invalid connection string.  Should be username:password@hostname."
          end
        end
      end
    end
  end
end

