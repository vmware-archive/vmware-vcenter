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
    end
  end
end

