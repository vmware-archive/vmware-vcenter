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
    Puppet.notice "A Virtual Machine is being migrated from datastore '#{get_vm_ds}' to '#{value}'."
    begin
      ds_view = get_ds_view(value)
      raise Puppet::Error, "Unable to find the target datastore '#{value}' because the target datastore is either invalid or does not exist." unless ds_view
      relocate_vm(:ds_view => ds_view)
    rescue Exception => excep
      Puppet.err "Unable to perform the Virtual Machine migration operation because of the following error:\n #{excep.message}"
    end

  end

  # Method to migrate Virtual machine from one host to another
  def migratevm_host=(value)
    Puppet.notice "A Virtual Machine is being migrated from  host '#{get_vm_host}' to '#{value}'."
    begin
      host_view = get_host_view(value)
      raise Puppet::Error, "Unable to find the host '#{value}' because the host is either invalid or does not exist." unless host_view
      relocate_vm(:host_view => host_view)

    rescue Exception => excep
      Puppet.err "Unable to perform the Virtual Machine migration operation because of the following error:\n #{excep.message}"
    end

  end

  # Method to relocate Virtual machine from one host to another and from one datastore to another
  def migratevm_host_datastore=(value)
    # Getting target_host
    target_host = value.split(",").first.strip
    # Getting target_datastore
    target_datastore = value.split(",").last.strip
    Puppet.notice "A Virtual Machine is being migrated from  from host '#{get_vm_host}' to '#{target_host}' and from datastore '#{get_vm_host}' to '#{get_vm_ds}'."
    begin
      host_view = get_host_view(target_host)
      raise Puppet::Error, "Unable to find the host '#{target_host}' because the host is either invalid or does not exist." unless host_view
      ds_view = get_ds_view(target_datastore)
      raise Puppet::Error, "Unable to find the target datastore '#{target_datastore}' because the target datastore is either invalid or does not exist." unless ds_view
      relocate_vm(:ds_view => ds_view , :host_view => host_view )
    rescue Exception => excep
      Puppet.err "Unable to perform the Virtual Machine migration operation because of the following error:\n #{excep.message}"
    end
  end

  def get_host_view(target_host)
    dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
    return vim.searchIndex.FindByDnsName(:datacenter => dc , :dnsName => target_host, :vmSearch => false)
  end

  def get_ds_view(target_datastore)
    dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
    ds ||= dc.find_datastore(target_datastore)
    return ds
  end

  def relocate_vm(args={})
    # initilizing the default values
    args[:host_view] ||= nil
    args[:ds_view] ||= nil

    host_view = args[:host_view]
    ds_view = args[:ds_view]

    spec_input = Hash.new
    disk_format = resource[:disk_format]
    if !ds_view.nil?
      spec_input[:datastore] = ds_view
      if !disk_format.eql?('same_as_source')
        transform = RbVmomi::VIM.VirtualMachineRelocateTransformation(disk_format);
        spec_input[:transform] = transform
      end
    end
    if !host_view.nil?
      spec_input[:host] = host_view
      spec_input[:pool] = host_view.parent.resourcePool
    end
    spec = RbVmomi::VIM.VirtualMachineRelocateSpec(spec_input)
    vm.RelocateVM_Task( :spec => spec).wait_for_completion
  end
  
  def get_vm_host
    vm.runtime.host.name
  end
  
  def get_vm_ds
    vm.storage.perDatastoreUsage[0].datastore.name
  end

  private

  def vm
    vmname = resource[:name]
    dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
    vm ||=dc.find_vm(vmname)
    raise Puppet::Error, "Unable to find the Virtual Machine '#{vmname}' because the specified Virtual machine is either invalid or does not exist." unless vm
    return vm
  end
end
