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
      result = Nori.parse(rest[url].send(m))
      Puppet.debug "VShield REST API #{m} #{url} result:\n#{result.inspect}"
      result
    end
  end

  [:put, :post].each do |m|
    define_method(m) do |url, data|
      result = rest[url].send(m, Gyoku.xml(data), :content_type => 'application/xml; charset=UTF-8')
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
    raise Puppet::Error "vSphere API connection failure: vShield #{resource[:transport]} not connected to vCenter." unless server
    connection = resource.catalog.resources.find{|x| x.class == Puppet::Type::Transport && x[:server] == server}.to_hash
    raise Puppet::Error "vSphere API connection failure: vCenter #{server} connection not available in manifest." unless connection
    connection
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
    Puppet.debug "@instance = #{@instance}"
    @edge_detail ||= get("api/3.0/edges/#{@instance['id']}")['edge']
  end

  def datacenter_moref(name=resource[:datacenter_name])
    dc = vim.serviceInstance.find_datacenter(name) or raise Puppet::Error, "datacenter '#{name}' not found."
    dc._ref
  end

  def ipset_detail
    @scope_moref = ''
    if resource[:scope_type].to_s == 'datacenter'
      @scope_moref = datacenter_moref(resource[:scope_name])
      Puppet.debug("datacenter_id = #{datacenter_id.inspect}")
    else
      result = edge_summary || []
      instance = result.find{|x| x['name'] == resource[:scope_name]}
      #Puppet.debug("instance = #{instance['id'].inspect}")
      @scope_moref = instance['id']
    end
    #get_all_ipsets("/api/2.0/services/ipset/scope/#{@scope_moref}")
    [get("/api/2.0/services/ipset/scope/#{@scope_moref}")].flatten
  end 
end
