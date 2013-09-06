# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_advanced_options) do
  @doc = "Manage vCenter esx advanced options."

  newparam(:host, :namevar => true) do
    desc "ESX hostname or ip address."
  end

  newproperty(:options) do
    desc "a hash with options and values"
  end

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:name]
  end

end
