# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_alarm) do
  @doc = "Manage vCenter esx hosts alarm."

  ensurable

  newparam(:name, :namevar => true) do
  end

  newparam(:host) do
  end

  newparam(:datacenter) do
  end

  autorequire(:vc_host) do
    self[:host]
  end
end
