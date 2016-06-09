# Copyright (C) 2014 VMware, Inc.
module_lib    = Pathname.new(__FILE__).parent.parent.parent.parent

require File.join module_lib, 'puppet_x/vmware/mapper'
require File.join module_lib, 'puppet/provider/vcenter'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet_x/vmware/util'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet/property/vmware'

Puppet::Type.type(:vm_harddisk).provide(:vm_harddisk, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manage a vCenter VM's virtual disk settings. See http://pubs.vmware.com/vsphere-55/index.jsp#com.vmware.wssdk.apiref.doc/vim.vm.device.VirtualDisk.html for class details"

  ##### begin common provider methods #####
  # besides name, these methods should look exactly the same for all providers
  # ensurable resources will have create, create_message, exist? and destroy

  map ||= PuppetX::VMware::Mapper.new_map('VirtualDiskMap')

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

  define_method(:map) do
    @map ||= map
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
    config_is_now
  end

  def config_should
    @config_should ||= config_hash config_is_now
  end

  ##### begin standard provider methods #####
  # these methods should exist in all ensurable providers, but content will diff

  def config_is_now
    @config_is_now ||= virtualDisk 
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
  alias set_level level=
  # Override level= to include setting the shares based off Enum SharesInfo http://pubs.vmware.com/vsphere-55/index.jsp#com.vmware.wssdk.apiref.doc/vim.SharesInfo.Level.html
  def level=(value)
    @flush_required = true
    self.set_level value.to_s
    case value
    when :high
      num_shares=2000
    when :normal
      num_shares=1000
    when :low
      num_shares=500
    when :custom
      raise Puppet::Error, "#{resource.inspect} must include property 'shares' when setting 'level' to 'custom'" unless resource[:shares]
      num_shares=resource[:shares]
    end
    self.shares=num_shares
  end

  # Override attributes of backing because map.objectify has issues with the backing class
  alias set_disk_mode disk_mode=
  def disk_mode=(value)
    @flush_required = true
    backing.diskMode = value.to_s
  end

  alias set_write_through write_through=
  def write_through=(value)
    @flush_required = true
    backing.writeThrough = value.to_s 
  end

  # Override controller to convert display name into controllerKey
  alias get_controller controller
  def controller
    currentController = vm.config.hardware.device.find { |d| d.key == config_is_now[:controllerKey] }
    currentController.deviceInfo.label if currentController
  end

  alias set_controller controller=
  def controller=(value)
    @flush_required = true
    config_should[:controllerKey] = newController.key
    config_should[:unitNumber]    = unitNumber
  end

  ##### begin private provider specific methods section #####
  # These methods are provider specific and that can be private
  private
 
  # Convert config_is_now into a hash to work with PuppetX::VMware::Util::nested_value
  # Removes backing from hash because map.objectify has issues with backing class
  def config_hash(config)
    newHash = {}
    if config
      nodes = []
      map.node_list.each { |node| nodes << node.node_type}
      config.props.each do |k,v|
        if nodes.include? v.class.to_s
          newHash[k] = config_hash v
        else
          newHash[k] = v
        end
      end
      newHash.delete(:backing)
    else
      newHash[:key] = -100
    end
    newHash
  end

  def datacenter(name=resource[:datacenter])
    vim.serviceInstance.find_datacenter(name) or raise Puppet::Error, "datacenter '#{resource[:datacenter]}' not found."
  end

  def vm
    @vm ||= findvm(datacenter.vmFolder, resource[:vm_name]) or raise Puppet::Error, "Unable to locate VM with the name '#{resource[:vm_name]}' "
  end

  def datastore
    @datastore ||= datacenter.datastoreFolder.children.find { |d| d.name.downcase == resource[:datastore].downcase } or raise Puppet::Error, "#{resource.inspect} unable to locate datastore '#{resource[:datastore]}' in datacenter '#{resource[:datacenter]}'"
  end

  def virtualDisk
    vm.config.hardware.device.find { |d| d.deviceInfo.label.downcase == resource[:name].downcase }
  end

  def reconfigVM(operation)
    vm.ReconfigVM_Task(
      :spec => virtualMachineConfigSpec( operation )
    ).wait_for_completion
  end

  def virtualMachineConfigSpec(operation)
    deviceSpec = map.objectify config_should
    # Add backing back in after map.objectify
    deviceSpec.backing = backing 
    spec = {
      :operation => operation,
      :device    => deviceSpec
    }
    spec.merge!( :fileOperation => :create ) if operation == :add
    spec.merge!( :fileOperation => :destroy ) if resource[:remove_disk] && operation == :remove
    virtualDeviceConfigSpec = RbVmomi::VIM::VirtualDeviceConfigSpec( spec )
    @virtualMachineConfigSpec = RbVmomi::VIM::VirtualMachineConfigSpec(
      :deviceChange => [ virtualDeviceConfigSpec ]
    )
  end

  def backing
    @backing ||= config_is_now ? config_is_now[:backing] : virtualDiskFlatVer2BackingInfo 
  end

  def virtualDiskFlatVer2BackingInfo
    b = RbVmomi::VIM::VirtualDiskFlatVer2BackingInfo.new(:thinProvisioned => resource[:thin_provisioned].to_s, :fileName => fileName)
    b.eagerScrub = resource[:eager_scrub] unless resource[:eager_scrub].nil?
    b
  end

  def newController
    @newController ||= vm.config.hardware.device.find { |d| d.deviceInfo.label.downcase == resource[:controller].downcase } or raise Puppet::Error, "#{resource.inspect} unable to locate controller '#{resource[:controller]}' on VM '#{resource[:vm_name]}'"
  end

  def unitNumber
    used = []
    vm.config.hardware.device.each { |d| used << d.unitNumber if d.controllerKey == newController.key }
    (0..15).each do |id|
      break if @unitNumber
      @unitNumber ||= id unless used.include? id || id = 7
    end
    Puppet.debug "#{resource[:controller]} setting unitNumber to '#{@unitNumber}'"
    @unitNumber
  end

  def fileName
    "[#{datastore.name}] #{resource[:vm_name]}/#{resource[:vm_name]}#{fileSuffix}"
  end

  def fileSuffix
    used = []
    vm.disks.each do |disk|
      vmdk = disk.backing.fileName.split('/')[1]
      if vmdk == "#{resource[:vm_name]}.vmdk"
        used << 0
      else
        used << vmdk.slice(/_\d.vmdk/).slice(/\d/).to_i
      end
    end
    #Max number of SCSI targers per VM https://www.vmware.com/pdf/vsphere5/r55/vsphere-55-configuration-maximums.pdf
    (0..60).each do |id|
      break if @suffixId
      @suffixId ||= id unless used.include? id
    end
    if @suffixId == 0
      suffix = ".vmdk"
    else
      suffix = "_#{@suffixId}.vmdk"
    end
    suffix
  end
end
