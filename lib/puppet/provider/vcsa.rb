require 'lib/puppet_x/puppetlabs/transport'
require 'lib/puppet_x/puppetlabs/transport/ssh'

class Puppet::Provider::Vcsa <  Puppet::Provider

  def self.transport(resource)
    @transport ||= PuppetX::PuppetLabs::Transport.retrieve(resource[:transport], resource.catalog, 'ssh')
  end

  def transport
    self.class.transport(resource)
  end
end
