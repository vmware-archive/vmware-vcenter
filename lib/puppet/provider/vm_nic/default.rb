# Copyright (C) 2014 VMware, Inc.
module_lib    = Pathname.new(__FILE__).parent.parent.parent.parent

require File.join module_lib, 'puppet_x/vmware/mapper'
require File.join module_lib, 'puppet/provider/vcenter'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet_x/vmware/util'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet/property/vmware'

Puppet::Type.type(:vm_nic).provide(:vm_nic, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manage a vCenter VM's virtual network adapter settings. See http://pubs.vmware.com/vsphere-55/index.jsp#com.vmware.wssdk.apiref.doc/vim.vm.device.VirtualEthernetCard.html for class details"

  ##### begin common provider methods #####
  # besides name, these methods should look exactly the same for all providers
  # ensurable resources will have create, create_message, exist? and destroy

  map ||= PuppetX::VMware::Mapper.new_map('VirtualEthernetCardMap')

  define_method(:map) do
    @map ||= map
  end

  def create
    @flush_required = true
    @create_message ||= []
    # fetch properties from resource using provider setters
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

  map.leaf_list.each do |leaf|
    Puppet.debug "Auto-discovered property [#{leaf.prop_name}] for type [#{self.name}]"

    define_method(leaf.prop_name) do
      Puppet.debug "#{leaf.path_is_now} set to #{PuppetX::VMware::Util::nested_value(config_is_now, leaf.path_is_now)}"
      value = PuppetX::VMware::Mapper::munge_to_tfsyms.call(
        PuppetX::VMware::Util::nested_value(config_is_now, leaf.path_is_now)
      )
    end

    define_method("#{leaf.prop_name}=".to_sym) do |value|
      PuppetX::VMware::Util::nested_value_set config_should, leaf.path_should, value, transform_keys=false
      @flush_required = true
    end
  end

  def exists?
    Puppet.debug "Evaluating '#{resource.inspect}' => #{resource.to_hash}"
    config_is_now
  end

  ##### begin standard provider methods #####
  # these methods should exist in all ensurable providers, but content will diff

  def config_should
    @config_should ||= config_hash || {}
  end

  def config_is_now
    @config_is_now ||= map.annotate_is_now(virtual_network_card) if virtual_network_card
  end

  def flush
    if @flush_required
      operation = config_is_now ? :edit : :add
      reconfigVM( operation )
    end
  end

  def destroy
    reconfigVM( :remove )
  end

  ##### begin misc provider specific methods #####
  # This section is for overrides of automatically-generated property getters and setters. Many
  # providers don't need any overrides. The most common use of overrides is to allow user input
  # of component names instead of object IDs (REST APIs) or Managed Object References (SOAP APIs).
  alias get_portgroup portgroup
  def portgroup
    case config_is_now[:backing].class.to_s 
    when 'VirtualEthernetCardDistributedVirtualPortBackingInfo'
      pg = datacenter.network.find {|n| n.key == config_is_now[:backing][:port][:portgroupKey] if n.class.to_s == 'DistributedVirtualPortgroup'}
      pg.name
    when 'VirtualEthernetCardNetworkBackingInfo'
      config_is_now[:backing][:deviceName]
    else
      raise Puppet::Error, "#{resource.inspect} returned unrecognized backing class: '#{config_is_now[:backing].class.to_s}'"
    end
  end

  alias set_portgroup portgroup=
  def portgroup=(value)
    case resource[:portgroup_type]
    when :distributed
      port = RbVmomi::VIM::DistributedVirtualSwitchPortConnection(
        :portgroupKey => distributedPortgroup.key,
        :switchUuid   => distributedPortgroup.config.distributedVirtualSwitch.uuid
      )
      config_should[:backing] = RbVmomi::VIM::VirtualEthernetCardDistributedVirtualPortBackingInfo(:port => port)
    when :standard
      config_should[:backing] = RbVmomi::VIM::VirtualEthernetCardNetworkBackingInfo(
        :deviceName => standardPortgroup.name,
      )
    else
      raise Puppet::Error, "#{resource.inspect} missing parameter 'portgroup_type': valid values [distrubuted, standard]"
    end
    @flush_required = true
  end

  alias get_type type
  def type
    case virtual_network_card.class.to_s
    when 'VirtualE1000'
      'e1000'
    when 'VirtualE1000e'
      'e1000e'
    when 'VirtualVmxnet2'
      'vmxnet2'
    when 'VirtualVmxnet3'
      'vmxnet3'
    else
      raise Puppet::Error, "#{resource.inspect} returned an unrecognized network card type"
    end
  end

  alias set_type type=
  def type=(value)
    @newType = true
    @flush_required = true
  end

  ##### begin private provider specific methods section #####
  # These methods are provider specific and that can be private
  private

  def config_hash
    config = {}
    if config_is_now
      config[:connectable] = config_is_now[:connectable].props
      config[:key]         = config_is_now[:key]
    else
      config[:key]         = -100
    end
    config
  end
 
  def virtual_network_card
    vm.config.hardware.device.find { |d| d.deviceInfo.label.downcase == resource[:name].downcase }
  end

  def distributedPortgroup
    @distributedPortgroup ||= datacenter.network.find {|n| n.name == resource[:portgroup] if n.class.to_s == 'DistributedVirtualPortgroup'} or raise Puppet::Error, "#{resource.inspect} unable to find distrubuted portgroup '#{resource[:portgroup]}' in datacenter '#{resource[:datacenter]}'."
  end

  def standardPortgroup
    @standardPortgroup ||= datacenter.network.find {|n| n.name == resource[:portgroup] if n.class.to_s == 'Network'} or raise Puppet::Error, "#{resource.inspect} unable to find standard portgroup '#{resource[:portgroup]}' in datacenter '#{resource[:datacenter]}'."
  end

  def reconfigVM(operation)
    vm.ReconfigVM_Task(
      :spec => virtualMachineConfigSpec( operation )
    ).wait_for_completion
  end

  def virtualMachineConfigSpec(operation)
    deviceSpec = map.objectify config_should
    if @newType
      nicType = resource[:type]
    else
      nicType = config_is_now.class.to_s
    end

    deviceSpec = 
     begin
        case nicType
        when :e1000, 'VirtualE1000'
          RbVmomi::VIM::VirtualE1000( deviceSpec.props )
        when :e1000e, 'VirtualE1000e'
          RbVmomi::VIM::VirtualE1000e( deviceSpec.props )
        when :vmxnet2, 'VirtualVmxnet2'
          RbVmomi::VIM::VirtualVmxnet2( deviceSpec.props )
        when :vmxnet3, 'VirtualVmxnet3'
          RbVmomi::VIM::VirtualVmxnet3( deviceSpec.props )
        end
     end
    spec = {
      :operation => operation,
      :device    => deviceSpec
    }

    virtualDeviceConfigSpec = RbVmomi::VIM::VirtualDeviceConfigSpec( spec )
    
    @virtualMachineConfigSpec = RbVmomi::VIM::VirtualMachineConfigSpec(
      :deviceChange => [ virtualDeviceConfigSpec ]
    )
  end

  def datacenter(name=resource[:datacenter])
    vim.serviceInstance.find_datacenter(name) or raise Puppet::Error, "datacenter '#{resource[:datacenter]}' not found."
  end

  def vm
    @vm ||= findvm(datacenter.vmFolder, resource[:vm_name]) or raise Puppet::Error, "Unable to locate VM with the name '#{resource[:vm_name]}' "
  end

end
