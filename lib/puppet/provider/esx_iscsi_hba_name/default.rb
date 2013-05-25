# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_iscsi_hba_name).provide(:esx_iscsi_hba_name, :parent => Puppet::Provider::Vcenter) do
  @doc = "Sets the iscsi name of a the target HBA."

  def iscsi_name
    hba.iScsiName
  end

  def iscsi_name=(value)
    esxhost.configManager.storageSystem.UpdateInternetScsiName(:iScsiHbaDevice => resource[:hba_name],
     :iScsiName => value)
  end

  private
  def esxhost
    @esxhost ||= vim.searchIndex.FindByDnsName(:dnsName => @resource[:esx_host],
      :vmSearch => false)
  end

  def hba
    @hba ||= esxhost.configManager.storageSystem.storageDeviceInfo.hostBusAdapter.find{|a|
      a.device == resource[:hba_name]}
  end
end

