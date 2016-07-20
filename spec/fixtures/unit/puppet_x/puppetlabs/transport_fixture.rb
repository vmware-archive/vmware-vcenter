require 'puppet_x/puppetlabs/transport'
require 'puppet_x/puppetlabs/transport/vsphere'

class Vcenter
  class Spec_fixtures
    class Transport

      attr_accessor :transport 

      def initialize( server="test.local", username="test", password="test123", options={})
        @transport = PuppetX::Puppetlabs::Transport::Vsphere.new(
          :server => server,
          :username => username,
          :password => password,
          :options  => options
        )
      end
    end

    ## Holding name to identify that the correct methods are called.
    class VimObject
    end
    
    class FolderObject
    end

  end
end



