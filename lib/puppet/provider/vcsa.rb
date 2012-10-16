require 'lib/puppet/modules/vcsa/transport'

class Puppet::Provider::Vcsa <  Puppet::Provider

  def self.transport(resource)
    name = Puppet::Resource.new(nil, resource[:transport].to_s).title
    trans = resource.catalog.resource(resource[:transport].to_s).to_hash
    Puppet::Modules::Vcsa::Transport.current(name) || Puppet::Modules::Vcsa::Transport.new(trans[:name], trans[:username], trans[:password], trans[:server])
  end

  def transport
    self.class.transport(resource)
  end

end
