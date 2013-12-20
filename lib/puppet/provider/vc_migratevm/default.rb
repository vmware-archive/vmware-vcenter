provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:vc_migratevm).provide(:vc_migratevm, :parent => Puppet::Provider::Vcenter) do
  @doc = "Migrate vCenter Virtual Machines."
  def exists?
    vm
  end

  # Get methods

  # Migrate VM host.
  def migratevm_host
    begin
      vm.runtime.host.name
    rescue Exception => exception
      Puppet.err exception.message
    end

  end

  # Migrate VM host.
  def migratevm_datastore
    begin
      vm.storage.perDatastoreUsage[0].datastore.name
    rescue Exception => exception
      Puppet.err exception.message
    end

  end

  # Migrate VM host.
  def migratevm_host_datastore
    begin
      vm.runtime.host.name +", "+vm.storage.perDatastoreUsage[0].datastore.name
    end
  rescue Exception => exception
    Puppet.err exception.message
  end

  # Set methods

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
        spec = RbVmomi::VIM.VirtualMachineRelocateSpec(:datastore => ds , :transform => disk_format)
      end
      vm.RelocateVM_Task( :spec => spec).wait_for_completion
    rescue Exception => excep
      Puppet.err excep.message
    end

  end

  def migratevm_host=(value)
    # Functionality implemented but not tested part of 3 sprint
    Puppet.notice "A Virtual Machine is being migrated from  host '"+value+"' to '"+value+"'."
    begin
      dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
      host_view = vim.searchIndex.FindByDnsName(:datacenter => dc , :dnsName => value, :vmSearch => false)
      if !host_view
        raise Puppet::Error, "Unable to find the host '"+value+"' because the host is either invalid or does not exist."
      end
      vm.MigrateVM_Task(:host => host_view, :priority => 'defaultPriority' , :state => 'poweredOff' ).wait_for_completion
    rescue Exception => excep
        puts "got some error"
      Puppet.err excep.message
    end

  end

  def migratevm_host_datastore=(value)
    # Functionality implemented but not tested part of 3 sprint
    Puppet.notice "A Virtual Machine is being migrated from  from host '"+value+"' to '"+value+"' and from datastore '" + vm.storage.perDatastoreUsage[0].datastore.name + "' to '"+value+"'."
    target_host = value.split(",").first.strip
    target_datastore = value.split(",").end.strip
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
        spec = RbVmomi::VIM.VirtualMachineRelocateSpec(:host => host_view , :datastore => ds)
      else
        spec = RbVmomi::VIM.VirtualMachineRelocateSpec(:host => host_view , :datastore => ds , :transform => disk_format)
      end
      vm.RelocateVM_Task( :spec => spec).wait_for_completion
    rescue Exception => excep
      Puppet.err excep.message
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
