# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_datastore).provide(:esx_datastore, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter CIFS/NFS (file) datastores."

  def create
	Puppet.debug "Creating datastore on the host."
	begin
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
		  attempt = 3
		  while ! create_vmfs_lun and ! exists? and attempt > 0
			Puppet.debug('Rescanning for volume')
			host.configManager.storageSystem.RescanAllHba() unless find_disk
			host.configManager.storageSystem.RescanVmfs()
			# Sleeping because scanning is async:
			# http://pubs.vmware.com/vsphere-51/index.jsp#com.vmware.wssdk.apiref.doc/vim.host.StorageSystem.html#rescanAllHba
			sleep 5

			attempt -= 1
		  end
		  raise("LUN #{resource[:lun]} not detected.") unless exists?
		end
	rescue Exception => excep
		Puppet.err "Unable to perform the operation because the following exception occurred - "
		Puppet.err excep.message
    end
  end

  def find_disk
    @disk ||= host.configManager.datastoreSystem.QueryAvailableDisksForVmfs().
                find_all{|disk| scsi_lun(disk.uuid) == resource[:lun]}.last
  end

  def create_vmfs_lun
    if host_scsi_disk = find_disk
      vmfs_ds_options = host.configManager.datastoreSystem.QueryVmfsDatastoreCreateOptions(
        :devicePath => host_scsi_disk.devicePath)
      # Use the 1st (only?) spec provided by the QueryVmfsDatastoreCreateOptions call
      spec = vmfs_ds_options[0].spec
      # set the name of the soon to be created datastore
      spec.vmfs[:volumeName] = resource[:datastore]
      # create the datastore
      Puppet.debug("Creating VMFS volume #{resource[:datastore]} on device #{host_scsi_disk.canonicalName}")
      host.configManager.datastoreSystem.CreateVmfsDatastore(:spec => spec)
    else
      false
    end
  rescue RbVmomi::VIM::DuplicateName, RbVmomi::VIM::HostConfigFault => e
    if exists? 
      true
    else
      Puppet.debug("VMFS volume create failure: #{e.message}")
      false
    end
  end

  def destroy
	Puppet.debug "Deleting datastore from the host."
	
	begin
		 host.configManager.datastoreSystem.RemoveDatastore(:datastore => @datastore)
	rescue Exception => excep
		Puppet.err "Unable to perform the operation because the following exception occurred - "
		Puppet.err excep.message
	end
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
    if @host
      return @host
    else
      fail "Make sure to provide correct name or IP address of the host"
    end
  end

  def scsi_lun(uuid)
    adapters = host.configManager.storageSystem.storageDeviceInfo.scsiTopology.adapter
    result = adapters.collect{|a| a.target.collect{|t| t.lun}}.flatten.find{|lun| lun.key =~ /#{uuid}/}
    result.lun if result
  end
end
