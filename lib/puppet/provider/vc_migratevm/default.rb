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
    rescue Exception => e
      fail e.message
    end

  end

  # Method to get VM current datastore name.
  def migratevm_datastore
    begin
      vm.storage.perDatastoreUsage[0].datastore.name
    rescue Exception => e
      fail e.message
    end

  end

  # Method to get VM current host and datastore name.
  def migratevm_host_datastore
    begin
      source_host = vm.runtime.host.name
      source_datastore = vm.storage.perDatastoreUsage[0].datastore.name
      source = source_host, source_datastore
    end
  rescue Exception => e
    fail e.message
  end

  # Set methods

  # Method to relocate Virtual machine from one datastore to another
  def migratevm_datastore=(value)
    Puppet.notice "A Virtual Machine is being migrated from datastore '#{get_vm_ds}' to '#{value}'."
    begin
      ds_view = get_ds_view(value)
      raise Puppet::Error, "Unable to find the target datastore '#{value}' because the target datastore is either invalid or does not exist." unless ds_view
      relocate_vm(:ds_view => ds_view)
    rescue Exception => e
      fail "Unable to perform the Virtual Machine migration operation because of the following error:\n #{e.message}"
    end

  end

  # Method to migrate Virtual machine from one host to another
  def migratevm_host=(value)
    Puppet.notice "A Virtual Machine is being migrated from  host '#{get_vm_host}' to '#{value}'."
    begin
      host_view = get_host_view(value)
      raise Puppet::Error, "Unable to find the host '#{value}' because the host is either invalid or does not exist." unless host_view
      relocate_vm(:host_view => host_view)

    rescue Exception => e
      fail "Unable to perform the Virtual Machine migration operation because of the following error:\n #{e.message}"
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
    rescue Exception => e
      fail "Unable to perform the Virtual Machine migration operation because of the following error:\n #{e.message}"
    end
  end

  def get_host_view(target_host)
    dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
    return vim.searchIndex.FindByDnsName(:datacenter => dc , :dnsName => target_host, :vmSearch => false)
  end

  def get_ds_view(target_datastore)
    ds ||= datacenter.find_datastore(get_cluster_datastore(target_datastore))
    return ds
  end

  def get_cluster_datastore(target_datastore)
    vm_disk_usage = vm.storage.perDatastoreUsage.first.committed + vm.storage.perDatastoreUsage.first.uncommitted
    vm_datastore_name = vm.storage.perDatastoreUsage.first.datastore.name

    paths = %w(name info.url info summary summary.accessible summary.capacity summary.freeSpace)
    propSet = [{ :type => "Datastore", :pathSet => paths }]
    filterSpec = { :objectSet => cluster.datastore.map { |ds| { :obj => ds } }, :propSet => propSet }
    data = vim.propertyCollector.RetrieveProperties(:specSet => [filterSpec])
    datastore_info = data.map do |ds_info|
      size = ds_info["summary.capacity"]
      free = ds_info["summary.freeSpace"]
      used = size - free
      is_local = ds_info["name"].match(/local-storage-\d+/)
      info = {
          "name" => ds_info["name"], "size" => size, "free" => free, "used" => used,
          "info" => ds_info["info"], "summary" => ds_info["summary"], "is_local" => is_local
      }
      info if ds_info["summary.accessible"] && !is_local
    end

    datastore_info += get_cluster_storage_pods
    datastore_info.compact!

    #Sort order: Pod -> Remote Datastore -> Local Datastore (each sorted by free size)
    datastore_info.sort_by! {|h| [h["pod"] ? 0 : 1, h["is_local"] ? 1 : 0, -h["free"]]}

    if !target_datastore.empty?
      info = datastore_info.find { |d| d["name"] == target_datastore }
      raise("Datastore #{target_datastore} not found") unless info
      raise("In-sufficient space in datastore %s") % [target_datastore] unless free < vm_disk_usage
      info["name"]
    else
      # Reject the name of the datastore where VM is currently hosted
      datastore_info.reject! {|d| d["name"] == vm_datastore_name}
      datastore_selected = datastore_info.find { |d| d["free"] >= vm_disk_usage }
      raise("No datastore found with sufficient free space") unless datastore_selected
      Puppet.debug("Selected datastore: %s") % [datastore_selected["name"]]
      datastore_selected["name"]
    end
  end

  def get_cluster_storage_pods
    paths = %w(name summary.capacity summary.freeSpace)
    property_set = [{:type => "StoragePod", :pathSet => paths}]
    filter_spec = {:objectSet => datacenter.datastoreFolder.childEntity.map {|ds| {:obj => ds} }, :propSet => property_set}
    data = vim.propertyCollector.RetrieveProperties(:specSet => [filter_spec])
    datastore_info = data.map do |ds_info|
      size = ds_info["summary.capacity"]
      free = ds_info["summary.freeSpace"]
      used = size - free
      name = ds_info["name"]
      info = {
          "name" => name, "size" => size, "free" => free, "used" => used, "pod" => true, "obj" => ds_info.obj
      }
      info
    end.compact
    Puppet.debug("Found Storage Pods: %s") % [datastore_info]
    datastore_info
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

  def datacenter
    @datacenter ||= vim.serviceInstance.find_datacenter(resource[:datacenter])
  end

  def cluster(name=resource[:cluster])
    cluster = datacenter.find_compute_resource(name)
    raise Puppet::Error, "Unable to find the cluster '#{name}'" unless cluster
    cluster
  end
end
