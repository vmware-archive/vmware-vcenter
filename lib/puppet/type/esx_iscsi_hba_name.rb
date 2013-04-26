# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_iscsi_hba_name) do
  @doc = "Sets name of iSCSI HBA on ESX host."

  newparam(:host_hba, :namevar => true) do
    desc "<esxhost>:<hba>"

    munge do |value|
      @resource[:esx_host], @resource[:hba] = value.split(':',2)
      value
    end
  end

  newparam(:esx_host) do
  	desc "ESX host name"
  end

  newparam(:hba) do
  	desc "target iSCSI HBA"
  end

  newparam(:iscsi_name) do
  	desc "Desired name for iSCSI HBA"
  end

end