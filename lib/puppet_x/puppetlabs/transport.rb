module PuppetX
  module Puppetlabs
    module Transport
      @@instances = []

      # Accepts a puppet resource reference, resource catalog, and loads connetivity info.
      def self.retrieve(options={})
        unless res_hash = options[:resource_hash]
          catalog = options[:catalog]
          res_ref = options[:resource_ref].to_s
          name = Puppet::Resource.new(nil, res_ref).title
          res_hash = catalog.resource(res_ref).to_hash
        end

        provider = options[:provider]

        unless transport = find(name, provider)
          transport = PuppetX::Puppetlabs::Transport::const_get(provider.capitalize).new(res_hash)
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
