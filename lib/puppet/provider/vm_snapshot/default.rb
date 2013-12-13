# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:vm_snapshot).provide(:vm_snapshot, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manage vCenter VMs Snapshot Operation."
  def create
    puts "Creating the snapshot of the Virtual Machine."
    begin
      vm.CreateSnapshot_Task(:name=> resource[:name], :memory => false, :quiesce => true).wait_for_completion
    rescue Exception => e
      puts "Unable to perform the operation because the following exception occurred."
      puts e.message
    end
  end

  def destroy
  end

  def exists?
    puts "Inside the exists method."
    if(resource[:snapshot_operation] == nil)
      return false;
    else
      return true;
    end
  end

  def snapshot_operation
  end

  # Performs the snapshot operation
  def snapshot_operation=(value)
    begin
      ss_name = resource[:name]
      vmSnapshot = vm.snapshot
      if vmSnapshot == nil
        raise "Unable to find the Virtual Machine snapshot because the snapshot does not exist."
      end
      snapshot_list = vmSnapshot.rootSnapshotList
      snapshot = find_node(snapshot_list, ss_name)
      if value == :revert
	    puts "Reverting the snapshot of the Virtual Machine."
        snapshot.RevertToSnapshot_Task(:suppressPowerOn => false).wait_for_completion
      elsif value == :remove
	    puts "Removing the snapshot of the Virtual Machine."
        snapshot.RemoveSnapshot_Task(:removeChildren => false).wait_for_completion
      end
    rescue Exception => e
      puts "Unable to perform the operation because the following exception occurred."
      puts e.message
    end
  end

  private

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

  private

  def vm
    dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
    @vmObj ||= dc.find_vm(resource[:vm_name]) or abort "VM not found."
  end
end

