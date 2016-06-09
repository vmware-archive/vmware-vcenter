# Copyright (C) 2013 VMware, Inc.

provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vc_storagepod).provide(:vc_storagepod, :parent => Puppet::Provider::Vcenter) do
  
  @doc = "This resource allows for the creation of a Storage Cluster, as well as the addition of datastores to the Cluster."

  def create
    to_add        = []
    root_ds_names = ds.map{|d| d.name}
    @resource[:datastores].each do |ds_name|
      if root_ds_names.include?(ds_name)
        to_add << ds.find{|d| d.name == ds_name}
      else 
        fail "datastore object #{ds_name} not found"
      end
    end
    pod_ = dc.datastoreFolder.CreateStoragePod(:name => @resource[:name])
    pod_.MoveIntoFolder_Task(:list => to_add).wait_for_completion unless to_add.empty?
    configure_pod
  end

  def destroy
    pod.Destroy_Task.wait_for_completion
  end

  def exists?
    pod
  end

  def datastores
    pod.children.map{|ds| ds.name}
  end
  
  def datastores=(values)
    #remove from cluster
    to_remove = []
    pod.children.each do |child|
      to_remove << child unless values.include?(child.name)
    end
    #add to cluster
    to_add           = []
    cluster_ds_names = datastores
    root_ds_names    = ds.map{|d| d.name}
    values.each do |ds_name|
      if cluster_ds_names.include?(ds_name)
        #
      elsif root_ds_names.include?(ds_name)
        to_add << ds.find{|d|d.name == ds_name}
      else
        fail "datastore object #{ds_name} not found"
      end
    end
    dc.datastoreFolder.MoveIntoFolder_Task(:list => to_remove).wait_for_completion unless to_remove.empty?
    pod.MoveIntoFolder_Task(:list => to_add).wait_for_completion unless to_add.empty?
  end
      
  private

  def configure_pod
    configure_drs if @resource[:drs]
  end

  def configure_drs
    srm.ConfigureStorageDrsForPod_Task!({ pod: pod, spec: drs_spec, modify: true }).wait_for_completion
  end


  def dc
    @dc ||= locate(@resource[:datacenter], RbVmomi::VIM::Datacenter)
  end

  def pod
    @pod ||= dc.datastoreFolder.children.select{|d| RbVmomi::VIM::StoragePod === d}.find{|d|d.name == @resource[:name]}
  end

  def ds
    @ds ||= dc.datastoreFolder.children.select{|d| RbVmomi::VIM::Datastore === d}
  end

  def srm
    @srm ||= vim.serviceInstance.content.storageResourceManager
  end

  def drs_spec
    RbVmomi::VIM::StorageDrsConfigSpec.new(podConfigSpec: RbVmomi::VIM::StorageDrsPodConfigSpec.new(enabled: true, ioLoadBalanceEnabled: true))
  end

end
