# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_iscsi).provide(:esx_iscsi,
                  :parent => Puppet::Provider::Vcenter) do
  @doc = "Enables or disables internet iSCSI on ESX hosts."

  def create
    esxhost.configManager.storageSystem.UpdateSoftwareInternetScsiEnabled(:enabled => true)
  end

  def destroy
    esxhost.configManager.storageSystem.UpdateSoftwareInternetScsiEnabled(:enabled => false)
  end

  def exists?
    esxhost.config.storageDevice.softwareInternetScsiEnabled
  end

  private

  def esxhost
    host(@resource[:esx_host])
  end

end
