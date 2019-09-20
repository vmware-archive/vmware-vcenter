# Copyright (C) 2019 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'
require 'yaml'

Puppet::Type.type(:vc_vm_rdm).provide(:vc_vm_rdm, :parent => Puppet::Provider::Vcenter) do
  @doc = 'Processes RDM disks'

  def vm
    @vm ||= findvm_by_name(datacenter.vmFolder, resource[:name])
  end

  def datacenter(name=resource[:datacenter])
    @datacenter ||= vim.serviceInstance.find_datacenter(name) or raise(Puppet::Error, "datacenter '#{name}' not found.")
  end

  def remove_rdm_disks
    Puppet.debug("Removing RDM disks from #{vm.name}")
    rdm_disk_details = resource[:rdm_disk_details]
    disk_ids_to_remove = rdm_disk_details.collect do |_, disk_facts|
      disk_facts["OtherUIDs"]
    end
    rdm_disks = vm.config.hardware.device.find_all do |device|
      device if device.class == RbVmomi::VIM::VirtualDisk && device.backing.is_a?(RbVmomi::VIM::VirtualDiskRawDiskMappingVer1BackingInfo) &&
          disk_ids_to_remove.include?(device.backing.deviceName)
    end
    rdm_disk_remove_specs = rdm_disks.collect do |rdm_disk|
      RbVmomi::VIM.VirtualDeviceConfigSpec(
          :device => rdm_disk,
          :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation('remove')
      )
    end
    rdm_disk_config_spec = RbVmomi::VIM.VirtualMachineConfigSpec(
        :name => resource[:name],
        :deviceChange => rdm_disk_remove_specs
    )
    task = vm.ReconfigVM_Task(:spec => rdm_disk_config_spec)
    task.wait_for_completion
    raise("Failed to remove RDM disks from %s with error %s" % [vm.name, task.info[:error][:localizedMessage]]) if task.info[:state] == "error"
  end

  def add_rdm_disks
    rdm_disk_details = resource[:rdm_disk_details]
    disk_id_to_add = rdm_disk_details.collect do |_, disk_facts|
      disk_facts["OtherUIDs"]
    end
    rdm_disks = vm.config.hardware.device.find_all do |device|
      device if device.class == RbVmomi::VIM::VirtualDisk &&
        device.backing.is_a?(RbVmomi::VIM::VirtualDiskRawDiskMappingVer1BackingInfo) &&
        disk_id_to_add.include?(device.backing.deviceName)
    end
    return unless rdm_disks.empty?

    Puppet.debug("Adding RDM disks to #{vm.name}")
    rdm_device_change_spec = rdm_disk_specs
    config_spec = RbVmomi::VIM.VirtualMachineConfigSpec(
        :deviceChange => rdm_device_change_spec)
    task = vm.ReconfigVM_Task(:spec => config_spec)
    task.wait_for_completion
    raise("Failed to add RDM disks to %s with error %s" % [vm.name, task.info[:error][:localizedMessage]]) if task.info[:state] == "error"
  end

  def rdm_disk_specs
    specs = []
    unit = 1
    device_key = 1
    scsi_controller_key = 1
    Puppet.debug("Adding RDM disk specs")
    devices = vm.config.hardware.device
    scsis = devices.find_all { |dev| dev.is_a?(RbVmomi::VIM::ParaVirtualSCSIController)}
    controller_keys = scsis.map { |scsi| scsi.key if scsi.device.length < 15}
    for controller_key in controller_keys do
      unused_unit_numbers = []
      disks_connected_to_controller = devices.find_all { |dev| dev.is_a?(RbVmomi::VIM::VirtualDisk) && dev.controllerKey == controller_key}
      used_unit_numbers = disks_connected_to_controller.collect do |disk|
        disk.unitNumber
      end
      #Each SCSI controller will have 16 slots.Find the slot which is not occupied by other devices
      for unit_number in 0..15
        unused_unit_numbers.push(unit_number) unless used_unit_numbers.include? unit_number || unit_number == 7
      end

      if unused_unit_numbers.any?
        scsi_controller_key = controller_key
        unit = unused_unit_numbers.first
        break
      end
    end
    used_device_keys =  devices.collect do |device|
      device.key
    end
    for key in 1..60
      unless used_device_keys.include? key
        device_key = key
        break
      end
    end

    rdm_disk_details = resource[:rdm_disk_details]
    rdm_disk_details.each do |_, facts|
      disk_path = facts["DevfsPath"]
      disk_size = facts["DeviceSize"]
      specs << rdm_disk_spec(disk_path, disk_size, scsi_controller_key, unit, device_key)
    end

    specs
  end

  def rdm_disk_spec(device_name, size, controller_key, unit, key)
    disk = RbVmomi::VIM.VirtualDisk(
        :backing => rdm_disk_backing(device_name),
        :controllerKey => controller_key,
        :key => key,
        :unitNumber => unit,
        :capacityInKB => size.to_i * 1024
    )
    config = {
        :device => disk,
        :fileOperation => RbVmomi::VIM.VirtualDeviceConfigSpecFileOperation('create'),
        :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation('add')
    }
    RbVmomi::VIM.VirtualDeviceConfigSpec(config)
  end

  def rdm_disk_backing(device_name = nil)
    RbVmomi::VIM.VirtualDiskRawDiskMappingVer1BackingInfo(
        :diskMode => "persistent",
        :fileName => "",
        :compatibilityMode => "physicalMode",
        :deviceName => device_name,
    )
  end

  def exists?
    false
  end

end
