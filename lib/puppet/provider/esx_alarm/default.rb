# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'resolv'

Puppet::Type.type(:esx_alarm).provide(:esx_alarm, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages ESXi host alarm."

  def exists?
    @host_alarms = host.triggeredAlarmState

    @vm_alarms = []
    @vm_alarms = vm.triggeredAlarmState if resource[:vm_name] && vm

    @alarm = @host_alarms + @vm_alarms
  end

  def create
    # In future add option to add the alarm
  end

  def destroy
    @host_alarms.each do |alarm|
      alarm.alarm.RemoveAlarm
    end

    @vm_alarms.each do |alarm|
      alarm.alarm.RemoveAlarm
    end
  end

  def host
    @host ||= vim.searchIndex.FindByDnsName(:datacenter => datacenter , :dnsName => resource[:host], :vmSearch => false) or raise(Puppet::Error, "Unable to find the host '#{resource[:host]}")
  end

  def datacenter
    @datacenter ||= vim.serviceInstance.find_datacenter(resource[:datacenter]) or raise(Puppet::Error, "datacenter '#{resource[:datacenter]}' not found.")
  end

  def vm
    @vm ||= datacenter.vmFolder.childEntity.grep(RbVmomi::VIM::VirtualMachine).find {|v| v.name == resource[:vm_name]}
  end
end

