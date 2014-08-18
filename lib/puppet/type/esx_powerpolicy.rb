# Copyright (C) 2014 VMware, Inc.
Puppet::Type.newtype(:esx_powerpolicy) do
  @doc = "This resource allows setting of ESX power policy."

  newparam(:host, :namevar => true) do
    desc "ESX hostname or ip address."
  end

  newproperty(:current_policy) do
    desc "ESX Power Policy."
    newvalues(:static, :dynamic, :low)
  end

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:name]
  end
end
