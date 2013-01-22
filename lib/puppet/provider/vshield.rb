require 'pathname' # WORK_AROUND #14073 and #7788
module_lib = Pathname.new(__FILE__).parent.parent.parent
require File.join module_lib, 'puppet_x/puppetlabs/transport'
require File.join module_lib, 'puppet_x/puppetlabs/transport/vshield'
require File.join module_lib, 'puppet_x/puppetlabs/transport/vsphere'
require File.join module_lib, 'puppet_x/vmware/util'

if Puppet.features.vshield? and ! Puppet.run_mode.master?
  # Using Savon's library:
  require 'nori'
  require 'gyoku'
end

# TODO: Depending on number of shared methods, we might make Puppet::Provider::Vcenter parent:
class Puppet::Provider::Vshield <  Puppet::Provider
  confine :feature => :vshield

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

  def ensure_array(value)
    # Ensure results an array. If there's a single value the result is a hash, while multiple results in an array.
    case value
    when nil
      []
    when Array
      value
    when Hash
      [value]
    else
      raise Puppet::Error, "Unknown type for munging #{value.class}: '#{value}'"
    end
  end

  def edge_summary
    # TODO: This may exceed 256 pagesize limit.
    @edge_summary ||= ensure_array( nested_value( get('api/3.0/edges'), ['pagedEdgeList', 'edgePage', 'edgeSummary'] ) )
  end

  def edge_detail
    raise Puppet::Error, "edge not available" unless @instance
    @edge_detail ||= nested_value(get("api/3.0/edges/#{@instance['id']}"), ['edge'])
  end

  def datacenter_moref(name=resource[:datacenter_name])
    dc = vim.serviceInstance.find_datacenter(name) or raise Puppet::Error, "datacenter '#{name}' not found."
    dc._ref
  end

  def vshield_scope_moref(type=resource[:scope_type], name=resource[:scope_name])
    case type
      when :datacenter
        datacenter_moref(name)
      when :edge
        edges = edge_summary || []
        instance = edges.find{|x| x['name'] == name}
        raise Puppet::Error, "vShield Edge #{name} does not exist." unless instance
        instance['id']
      else
        raise Puppet::Error, "Unknown scope type #{type}"
      end
  end
end
