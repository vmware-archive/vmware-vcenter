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

  [:get, :delete].each do |m|
    define_method(m) do |url|
      begin
        result = Nori.parse(rest[url].send(m))
      rescue RestClient::Exception => e
        raise Puppet::Error, "\n#{e.exception}:\n#{e.response}"
      end
      Puppet.debug "VShield REST API #{m} #{url} result:\n#{result.inspect}"
      result
    end
  end

  [:put, :post].each do |m|
    define_method(m) do |url, data|
      begin
        result = rest[url].send(m, Gyoku.xml(data), :content_type => 'application/xml; charset=UTF-8')
      rescue RestClient::Exception => e
        raise Puppet::Error, "\n#{e.exception}:\n#{e.response}"
      end
      Puppet.debug "VShield REST API #{m} #{url} with #{data.inspect} result:\n#{result.inspect}"
    end
  end

  # We need the corresponding vCenter connection once vShield is connected
  def vim
    @vsphere_transport ||= PuppetX::Puppetlabs::Transport.retrieve(:resource_hash => connection, :provider => 'vsphere')
    @vsphere_transport.vim
  end

  def connection
    server = vc_info['ipAddress']
    raise Puppet::Error, "vSphere API connection failure: vShield #{resource[:transport]} not connected to vCenter." unless server
    connection = resource.catalog.resources.find{|x| x.class == Puppet::Type::Transport && x[:server] == server}
    raise Puppet::Error, "vSphere API connection failure: vCenter #{server} transport connection not available in manifest." unless connection
    connection.to_hash
  end

  def vc_info
    @vc_info ||= get('api/2.0/global/config')['vsmGlobalConfig']['vcInfo']
  end

  def nested_value(hash, keys, default=nil)
    value = hash.dup
    keys.each_with_index do |item, index|
      unless (value.is_a? Hash) && (value.include? item)
        default = yield hash, keys, index if block_given?
        return default
      end
      value = value[item]
    end
    value
  end

  def edge_summary
    # TODO: This may exceed 256 pagesize limit.
    @edge_summary ||= [get('api/3.0/edges')['pagedEdgeList']['edgePage']['edgeSummary']].flatten
  end

  def edge_detail
    raise Puppet::Error, "edge not available" unless @instance
    @edge_detail ||= get("api/3.0/edges/#{@instance['id']}")['edge']
  end

  def datacenter_moref(name=resource[:datacenter_name])
    dc = vim.serviceInstance.find_datacenter(name) or raise Puppet::Error, "datacenter '#{name}' not found."
    dc._ref
  end

  def get_detail(type)
    @scope_moref = ''
    if resource[:scope_type].to_s == 'datacenter'
      @scope_moref = datacenter_moref(resource[:scope_name])
    else
      result = edge_summary || []
      instance = result.find{|x| x['name'] == resource[:scope_name]}
      @scope_moref = instance['id']
    end
    [get("/api/2.0/services/#{type}/scope/#{@scope_moref}")].flatten
  end

end
