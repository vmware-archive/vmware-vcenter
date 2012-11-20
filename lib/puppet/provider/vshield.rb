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

class Puppet::Provider::Vshield <  Puppet::Provider

  private

  def rest
    @transport ||= PuppetX::Puppetlabs::Transport.retrieve(resource[:transport], resource.catalog, 'vshield')
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
end
