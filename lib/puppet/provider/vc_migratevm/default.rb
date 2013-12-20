provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:vc_migratevm).provide(:vc_migratevm, :parent => Puppet::Provider::Vcenter) do
  @doc = "Migrate vCenter Virtual Machines."
  def exists?
    vm
  end

  # Get methods

  # Method to get VM current host.
  def migratevm_host
    begin
      vm.runtime.host.name
    rescue Exception => exception
      Puppet.err exception.message
    end

  end

  # Method to get VM current datastore name.
  def migratevm_datastore
    begin
      vm.storage.perDatastoreUsage[0].datastore.name
    rescue Exception => exception
      Puppet.err exception.message
    end

  end

  # Method to get VM current host and datastore name.
  def migratevm_host_datastore
    begin
      source_host = vm.runtime.host.name
      source_datastore = vm.storage.perDatastoreUsage[0].datastore.name
      source = source_host, source_datastore
    end
  rescue Exception => exception
    Puppet.err exception.message
  end

  # Set methods

  # Method to relocate Virtual machine from one datastore to another
  def migratevm_datastore=(value)
    Puppet.notice "A Virtual Machine is being migrated from datastore '" + vm.storage.perDatastoreUsage[0].datastore.name + "' to '"+value+"'."
    begin
      dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
      ds ||= dc.find_datastore(value)
      if !ds
        raise Puppet::Error, "Unable to find the target datastore '" +value+"' because the target datastore is either invalid or does not exist."
      end
      disk_format = resource[:disk_format]
      if disk_format.eql?('same_as_source')
        spec = RbVmomi::VIM.VirtualMachineRelocateSpec(:datastore => ds)
      else
        transform = RbVmomi::VIM.VirtualMachineRelocateTransformation(disk_format);
        spec = RbVmomi::VIM.VirtualMachineRelocateSpec(:datastore => ds , :transform => transform)
      end
      vm.RelocateVM_Task( :spec => spec).wait_for_completion
    rescue Exception => excep
      Puppet.err "Unable to perform the Virtual Machine migration operation because of the following error:\n" + excep.message
    end

  end

  # Method to migrate Virtual machine from one host to another
  def migratevm_host=(value)
    Puppet.notice "A Virtual Machine is being migrated from  host '"+vm.runtime.host.name+"' to '"+value+"'."
    begin
      dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
      host_view = vim.searchIndex.FindByDnsName(:datacenter => dc , :dnsName => value, :vmSearch => false)
      if !host_view
        raise Puppet::Error, "Unable to find the host '"+value+"' because the host is either invalid or does not exist."
      end
      spec = RbVmomi::VIM.VirtualMachineRelocateSpec(:host => host_view , :pool => host_view.parent.resourcePool)
      vm.RelocateVM_Task( :spec => spec).wait_for_completion

    rescue Exception => excep
      Puppet.err "Unable to perform the Virtual Machine migration operation because of the following error:\n" + excep.message
    end

  end

  # Method to relocate Virtual machine from one host to another and from one datastore to another
  def migratevm_host_datastore=(value)
    # Getting target_host
    target_host = value.split(",").first.strip
    # Getting target_datastore
    target_datastore = value.split(",").last.strip
    Puppet.notice "A Virtual Machine is being migrated from  from host '"+vm.runtime.host.name+"' to '"+target_host+"' and from datastore '" + vm.storage.perDatastoreUsage[0].datastore.name + "' to '"+target_datastore+"'."
    begin
      dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
      host_view = vim.searchIndex.FindByDnsName(:datacenter => dc , :dnsName => target_host, :vmSearch => false)
      if !host_view
        raise Puppet::Error, "Unable to find the host '"+target_host+"' because the host is either invalid or does not exist."
      end
      ds ||= dc.find_datastore(target_datastore)
      if !ds
        raise Puppet::Error, "Unable to find the target datastore '" +target_datastore+"' because the target datastore is either invalid or does not exist."
      end
      disk_format = resource[:disk_format]
      if disk_format.eql?('same_as_source')
        spec = RbVmomi::VIM.VirtualMachineRelocateSpec(:host => host_view , :datastore => ds , :pool => host_view.parent.resourcePool)
      else
        transform = RbVmomi::VIM.VirtualMachineRelocateTransformation(disk_format);
        spec = RbVmomi::VIM.VirtualMachineRelocateSpec(:host => host_view , :datastore => ds , :transform => transform , :pool => host_view.parent.resourcePool)
      end
      vm.RelocateVM_Task( :spec => spec).wait_for_completion
    rescue Exception => excep
      Puppet.err "Unable to perform the Virtual Machine migration operation because of the following error:\n" + excep.message
    end
  end

  private

  def vm
    vmname = resource[:name]
    dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
    vm ||=dc.find_vm(vmname)
    if !vm
      raise Puppet::Error, "Unable to find the Virtual Machine '"+vmname+"' because the specified Virtual machine is either invalid or does not exist."
    else
      return vm
    end
  end
end
