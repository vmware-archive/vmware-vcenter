# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_datastore).provide(:esx_datastore, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter CIFS/NFS (file) datastores."

  def create
    volume = {}
    [:remote_host, :remote_path, :local_path, :access_mode].each do |prop|
      volume[PuppetX::VMware::Util.camelize(prop, :lower).to_sym] = resource[prop]
    end

    case resource[:type]
    when 'NFS'
      host.configManager.datastoreSystem.CreateNasDatastore(:spec => volume)
    when 'CIFS'
      volume[:type] = 'CIFS'
      volume[:userName] = resource[:user_name] if resource[:user_name]
      volume[:password] = resource[:password] if resource[:password]
      host.configManager.datastoreSystem.CreateNasDatastore(:spec => volume)
    when 'VMFS'
      found_lun = false
      host.configManager.storageSystem.RescanAllHba()
      host_scsi_disks = host.configManager.datastoreSystem.QueryAvailableDisksForVmfs()
      host_scsi_disks.each do |host_scsi_disk|
        if scsi_lun(host_scsi_disk.uuid) == resource[:lun]
          found_lun = true
          vmfs_ds_options = host.configManager.datastoreSystem.QueryVmfsDatastoreCreateOptions(
            :devicePath => host_scsi_disk.devicePath)
          # Use the 1st (only?) spec provided by the QueryVmfsDatastoreCreateOptions call
          spec = vmfs_ds_options[0].spec
          # set the name of the soon to be created datastore
          spec.vmfs[:volumeName] = resource[:datastore]
          # create the datastore
          host.configManager.datastoreSystem.CreateVmfsDatastore(:spec => spec)
        end
      end
      fail("LUN #{resource[:lun]} not detected.") unless found_lun
    end
  end

  def destroy
    host.configManager.datastoreSystem.RemoveDatastore(:datastore => @datastore)
  end

  def type
    @datastore.summary.type
  end

  def type=(value)
    warn "Can not change resource type."
  end

  def remote_host
    @datastore.info.nas.remoteHost
  end

  def remote_path
    @datastore.info.nas.remotePath
  end

  def exists?
    @datastore = host.datastore.find{|d|d.name==resource[:datastore]}
  end

  private

  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
  end

  def scsi_lun (uuid)
    @host.configManager.storageSystem.storageDeviceInfo.scsiTopology.adapter.each do |adapter|
      adapter.target.each do |target|
        target.lun.each do |lun_obj|
          # This is a hack to work around a RbVmomi bug
          #   where the scsiLun property is returned
          #   as a blank object rather than a string
          return lun_obj.lun if lun_obj.key =~ /#{uuid}/
        end
      end
    end
    nil
  end
end
