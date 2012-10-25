module PuppetX
  module Puppetlabs
    module Transport
      @@instances = []

      # Accepts a puppet resource reference, resource catalog, and loads connetivity info.
      def self.retrieve(resource, catalog, provider)
        name = Puppet::Resource.new(nil, resource.to_s).title
        options = catalog.resource(resource.to_s).to_hash

        unless transport = find(name, provider)
          transport = PuppetX::Puppetlabs::Transport::const_get(provider.capitalize).new(options)
          transport.connect
          @@instances << transport
        end

        transport
      end

      private

      def self.find(name, provider)
        @@instances.find{ |x| x.is_a? PuppetX::Puppetlabs::Transport::const_get(provider.capitalize) and x.name == name }
      end
    end
  end
end
