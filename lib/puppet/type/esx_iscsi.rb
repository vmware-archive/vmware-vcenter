# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_maintmode) do
  @doc = "Enables or disables iSCSI on an ESX host."

  ensurable

  newparam(:esx_host, :namevar => true) do
    desc "ESX hostname"
  end

end
