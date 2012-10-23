require 'lib/puppet/modules/transport'
require 'lib/puppet/modules/transport/ssh'

class Puppet::Provider::Vcsa <  Puppet::Provider

  def self.transport(resource)
    @transport ||= Puppet::Modules::Transport.retrieve(resource[:transport], resource.catalog, 'ssh')
  end

  def transport
    self.class.transport(resource)
  end
end
