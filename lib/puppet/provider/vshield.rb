require 'pathname' # WORK_AROUND #14073 and #7788
module_lib = Pathname.new(__FILE__).parent.parent.parent
require File.join module_lib, 'puppet_x/puppetlabs/transport'
require File.join module_lib, 'puppet_x/puppetlabs/transport/vshield'
require File.join module_lib, 'puppet_x/puppetlabs/transport/vsphere'
require File.join module_lib, 'puppet_x/vmware/util'

unless Puppet.run_mode.master?
  # Using Savon's library:
  require 'nori'
  require 'gyoku'
end

# TODO: Depending on number of shared methods, we might make Puppet::Provider::Vcenter parent:
class Puppet::Provider::Vshield <  Puppet::Provider

  private

  def rest
    @transport ||= PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => resource[:transport], :catalog => resource.catalog, :provider => 'vshield')
    @transport.rest
  end

  def get(url)
    result = Nori.parse(rest[url].get)
    Puppet.debug "VShield REST get #{url} result:\n#{result.inspect}"
    result
  end

  def put(url, data)
    result = rest[url].put Gyoku.xml(data), :content_type => 'application/xml; charset=UTF-8'
    Puppet.debug "VShield REST put #{url} with #{data.inspect} result:\n#{result.inspect}"
  end

  def post(url, data)
    result = rest[url].post Gyoku.xml(data), :content_type => 'application/xml; charset=UTF-8'
    Puppet.debug "VShield REST put #{url} with #{data.inspect} result:\n#{result.inspect}"
  end

  # We need the corresponding vCenter connection once vShield is connected
  def vim
    @vsphere_transport ||= PuppetX::Puppetlabs::Transport.retrieve(:resource_hash => connection, :provider => 'vsphere')
    @vsphere_transport.vim
  end

  def connection
    server = vc_info['ipAddress']
    raise Puppet::Error "vSphere API connection failure: vShield #{resource[:transport]} not connected to vCenter." unless server
    connection = resource.catalog.resources.find{|x| x.class == Puppet::Type::Transport && x[:server] == server}.to_hash
    raise Puppet::Error "vSphere API connection failure: vCenter #{ip_address} connection not available in manifest." unless connection
    connection
  end

  def vc_info
    @vc_info ||= get('api/2.0/global/config')['vsmGlobalConfig']['vcInfo']
  end
end
