# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_iscsi).provide(:esx_iscsi,
                  :parent => Puppet::Provider::Vcenter) do
  @doc = "Enables or disables internet iSCSI on ESX hosts."

  def create
    host.configManager.storageSystem.UpdateSoftwareInternetScsiEnabled(:enabled => true)
  end

  def destroy
    host.configManager.storageSystem.UpdateSoftwareInternetScsiEnabled(:enabled => false)
  end

  def exists?
    esxhost.config.storageDevice.softwareInternetScsiEnabled
  end

  private

  def esxhost
    @esxhost ||= vim.searchIndex.FindByDnsName(:dnsName => @resource[:esx_host],
      :vmSearch => false)
  end

end