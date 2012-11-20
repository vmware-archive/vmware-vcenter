require 'lib/puppet_x/puppetlabs/transport'
require 'lib/puppet_x/puppetlabs/transport/ssh'

class Puppet::Provider::Vcsa <  Puppet::Provider

  def self.transport(resource)
    @transport ||= PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => resource[:transport], :catalog => resource.catalog, :provider => 'ssh')
  end

  def transport
    self.class.transport(resource)
  end
end
