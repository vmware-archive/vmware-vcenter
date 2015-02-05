# Copyright (C) 2015 VMware, Inc.
require 'set'

require 'pathname'
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
module_lib = Pathname.new(__FILE__).parent.parent.parent.parent
Puppet.debug "module_lib = #{module_lib.inspect}"
Puppet.debug "File.join module_lib, 'puppet/provider/vcenter'  = #{File.join module_lib, 'puppet/provider/vcenter'}"
require File.join module_lib, 'puppet/provider/vcenter'
require File.join module_lib, 'puppet_x/vmware/mapper'

Puppet::Type.type(:vc_ip_pool).provide(:vc_ip_pool, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manage vCenter IpPools. http://pubs.vmware.com/vsphere-55/index.jsp#com.vmware.wssdk.apiref.doc/vim.vApp.IpPool.html"
  
  def self.map
    @map ||= PuppetX::VMware::Mapper.new_map('IpPoolMap')
  end

  def map
    self.class.map
  end

  map.leaf_list.each do |leaf|
    define_method(leaf.prop_name) do
      value = PuppetX::VMware::Mapper::munge_to_tfsyms.call(
        PuppetX::VMware::Util::nested_value(config_is_now, leaf.path_is_now)
      )
    end

    define_method("#{leaf.prop_name}=".to_sym) do |value|
      PuppetX::VMware::Util::nested_value_set(config_should, leaf.path_should, value)
      
      @flush_required = true
    end
  end

  def create
    @creating = true
    @create_message ||= []
    map.leaf_list.each do |leaf|
      p = leaf.prop_name
      unless (value = @resource[p]).nil?
        self.send("#{p}=".to_sym, value)
        @create_message << "#{leaf.full_name} => #{value.inspect}"
      end 
    end

  end

  def create_message
    @create_message ||= []
    "created using {#{@create_message.join ", "}}"
  end

  alias get_network_association network_association
  def network_association
    v = get_network_association
    networks = [] 
    v.each{|association| networks << {:networkName => association.networkName} } if v.is_a? Array
    networks
  end

  alias set_network_association network_association=
  def network_association= network_list
    portgroup_associations = []
    misses_list = []
    network_list.each do |network|
      network_name = network[:networkName] || network['networkName']
      moref = datacenter.networkFolder.children.find {|pg| pg.name == network_name}
      if moref
        portgroup_associations << {:network => moref._ref, :networkName => network_name}
      else
        misses_list << network_name
      end
    end
    if misses_list.empty?
      set_network_association portgroup_associations
    else
      raise Puppet::Error, "Unable to locate the following networks in datacenter '#{resource[:datacenter]}' : #{misses_list.inspect}"
    end
  end

  def exists?
    ip_pool
  end

  def destroy
    ip_pool_manager.DestroyIpPool(:dc => datacenter, :id => ip_pool.id, :force => resource[:force_destroy])
  end

  def flush
   Puppet.debug "config_is_now is #{config_is_now.inspect}"
   Puppet.debug "config_should is #{config_should.inspect}"
   if @creating
     ip_pool_manager.CreateIpPool(:dc => datacenter, :pool => config_should)
   elsif @flush_required  
     ip_pool_manager.UpdateIpPool(:dc => datacenter, :pool => config_should)
   end
  end

  def config_is_now
    @config_is_now ||= (@creating ? {} : map.annotate_is_now(ip_pool))
  end

  def config_should
    if ip_pool
      @config_should ||= {:id => ip_pool.id}
    else
      @config_should ||= {}
    end
  end

  def datacenter(name=resource[:datacenter])
    raise Puppet::Error, "Parameter 'datacenter' cannot be blank" if resource[:datacenter].nil?
    @datacenter ||= vim.serviceInstance.find_datacenter(name) or raise Puppet::Error, "datacenter '#{resource[:datacenter]}' not found."
  end

  def ip_pool_manager
    @ip_pool_manager ||= vim.serviceContent.ipPoolManager
  end

  def ip_pool
    raise Puppet::Error, "Parameter 'name' cannot be blank" if resource[:name].nil?
    @ip_pool ||= ip_pool_manager.QueryIpPools(:dc => datacenter).find {|pool| pool[:name] == resource[:name]}
  end
end
