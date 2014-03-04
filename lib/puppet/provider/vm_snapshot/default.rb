# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:vm_snapshot).provide(:vm_snapshot, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manage vCenter VMs Snapshot Operation."

  def exists?
    return true;
  end

  def snapshot_operation
  end

  # Performs the snapshot operation
  def snapshot_operation=(value)
    begin
      ss_name = resource[:name]
      if value == :create
        Puppet.info "Creating a Virtual Machine snapshot."
        vm.CreateSnapshot_Task(:name=> resource[:name], :memory => resource[:memory_snapshot], :quiesce => true).wait_for_completion
      else
        vmsnapshot = vm.snapshot
        if vmsnapshot == nil
          raise Puppet::Error, "Unable to find the Virtual Machine snapshot because the snapshot does not exist."
        end
        snapshot_list = vmsnapshot.rootSnapshotList
        snapshot = find_node(snapshot_list, ss_name)
        if snapshot == nil
          raise Puppet::Error, "Unable to find the Virtual Machine snapshot because the snapshot does not exist."
        end
        if value == :revert
          Puppet.info "Reverting a Virtual Machine snapshot."
          snapshot.RevertToSnapshot_Task(:suppressPowerOn => resource[:snapshot_supress_power_on]).wait_for_completion
        elsif value == :remove
          Puppet.info "Removing a Virtual Machine snapshot."
          snapshot.RemoveSnapshot_Task(:removeChildren => false).wait_for_completion
        end
      end
    rescue Exception => e
      Puppet.err "Unable to perform the operation because the following exception occurred."
      Puppet.err e.message
    end
  end

  private

  def vm
    begin
      dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
      @vmObj ||= dc.find_vm(resource[:vm_name]) or raise Puppet::Error, "Unable to find the Virtual Machine because the Virtual Machine does not exist."
    end
  end

  def find_node(tree, name)
    begin
      snapshot = nil
      tree.each do |node|
        if node.name == name
          snapshot = node.snapshot
        elsif !node.childSnapshotList.empty?
          snapshot = find_node(node.childSnapshotList, name)
        end
      end
      return snapshot
    rescue Exception => e
      puts "Unable to perform the operation because the following exception occurred."
      puts e.message
    end
  end

end

