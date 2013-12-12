# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'
Puppet::Type.type(:vm_snapshot).provide(:vm_snapshot, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manage vCenter VMs Snapshot Operation."
  def create
    puts "Inside Create Method."
    vm.CreateSnapshot_Task(name: resource[:snapshot_name], memory: false, quiesce: true).wait_for_completion
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
	ss_name = resource[:snapshot_name]
        snapshot_list = vm.snapshot.rootSnapshotList
        snapshot = find_node(snapshot_list, ss_name)
     if value == :revert
        snapshot.RevertToSnapshot_Task(:suppressPowerOn => false).wait_for_completion 
      elsif value == :remove
    	snapshot.RemoveSnapshot_Task(:removeChildren => false).wait_for_completion 
      end
  end

  private
def find_node(tree, name)
   snapshot = nil
   tree.each do |node|
      if node.name == name
        snapshot = node.snapshot
      elsif !node.childSnapshotList.empty?
        snapshot = find_node(node.childSnapshotList, name)
      end
    end
    return snapshot
  end
  
  private
  def vm
    dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
    @vmObj ||= dc.find_vm(resource[:name]) or abort "VM not found."
  end
end

