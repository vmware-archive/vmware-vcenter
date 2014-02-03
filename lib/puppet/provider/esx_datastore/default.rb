# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_datastore).provide(:esx_datastore, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter CIFS/NFS (file) datastores."
  def create
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
        target_iqn = resource[:target_iqn]
        if target_iqn
          raise("Target IQN '#{target_iqn}' not detected.") unless exists?
        else
          raise("LUN '#{resource[:lun]}' not detected.") unless exists?
        end
      end
    rescue Exception => excep
      Puppet.err "Unable to perform the operation because the following exception occurred - "
      Puppet.err excep.message
    end
  end

  def find_disk

    target_iqn = resource[:target_iqn]

    if target_iqn
      @disk ||= host.configManager.datastoreSystem.QueryAvailableDisksForVmfs().
      find_all{|disk| scsi_target_iqn(disk.uuid) == target_iqn }.last
    else
      @disk ||= host.configManager.datastoreSystem.QueryAvailableDisksForVmfs().
      find_all{|disk| scsi_lun(disk.uuid) == resource[:lun]}.last
    end

    return @disk
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
    begin
      host.configManager.datastoreSystem.RemoveDatastore(:datastore => host.datastore.find{|d|d.name==resource[:datastore]})
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
    if resource[:path]
      @host ||= vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
    else
      @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
    end

    if @host
      return @host
    else
      fail "An invalid host name or IP address is entered. Enter the correct host name and IP address."
    end
  end

  def scsi_lun(uuid)
    adapters = host.configManager.storageSystem.storageDeviceInfo.scsiTopology.adapter
    result = adapters.collect{|a| a.target.collect{|t| t.lun}}.flatten.find{|lun| lun.key =~ /#{uuid}/}
    result.lun if result
  end

  # Getting the target iqn for lun created on storage.
  def scsi_target_iqn(uuid)
    adapters = host.configManager.storageSystem.storageDeviceInfo.scsiTopology.adapter
    required_adapter_hash = nil
    found = 0
    iscsi_name = nil

    target_iqn = resource[:target_iqn]
    luntype = 'fc'
    if target_iqn =~ /^iqn/
      luntype = 'iscsi'
    end
    luntype = luntype.to_s
    Puppet.notice "luntype : #{luntype}"
    adapters.collect{|adapter|
      adapter.target.collect{|target|
        target.lun.collect{|lun|
          if lun.key =~ /#{uuid}/

            # fc.5000d310005ec401:5000d310005ec437
            if luntype.eql?('iscsi')
              # Added the following check to make sure 'iScsiName' exists as part of each disk HostTargetTransport data object.
              # Here , 'iScsiName' is instance variable of HostInternetScsiTargetTransport data object for given iScsi disk.
              if (defined?(target.transport.iScsiName))
                iscsi_name = target.transport.iScsiName
              else
                next
              end
            else
              nwwn_decimal = target.transport.nodeWorldWideName  #nwwn in decimal format
              nwwn_hexadecimal = nwwn_decimal.to_s(16) #nwwn in decimal hexadecimal format

              pwwn_decimal = target.transport.portWorldWideName #pwwn in decimal format
              pwwn_hexadecimal = pwwn_decimal.to_s(16) #pwwn in decimal hexadecimal format
              iscsi_name = "fc.#{nwwn_hexadecimal}:#{pwwn_hexadecimal}"
            end

            found = 1
            break
          end

        }
        if found.eql?(1)
          break
        end
      }
      if found.eql?(1)
        break
      end
    }
    iscsi_name unless iscsi_name.nil?
  end

  # To support the multiple datacenter in same vCenter.
  def walk_dc(path=resource[:path])
    datacenter = walk(path, RbVmomi::VIM::Datacenter)
    raise Puppet::Error.new( "Unable to find datacenter path: #{path}") unless datacenter
    datacenter
  end

end
