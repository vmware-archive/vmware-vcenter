require 'pathname' # WORK_AROUND #14073 and #7788
module_lib = Pathname.new(__FILE__).parent.parent.parent
require File.join module_lib, 'puppet_x/puppetlabs/transport'
require File.join module_lib, 'puppet_x/puppetlabs/transport/ssh'

class Puppet::Provider::Vcsa <  Puppet::Provider

  def self.transport(resource)
    @transport ||= PuppetX::Puppetlabs::Transport.retrieve(resource[:transport], resource.catalog, 'ssh')
  end

  def transport
    self.class.transport(resource)
  end
end
