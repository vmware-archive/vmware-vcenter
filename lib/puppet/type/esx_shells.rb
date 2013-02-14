# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_shells) do
  @doc = "Manage vCenter esx hosts config for shells (ESXi Shell and SSH)"

  newparam(:host, :namevar => true) do
    desc "ESX hostname or ip address."
  end

  newproperty(:suppress_shell_warning) do
    desc ""
    newvalues('0', '1')
    defaultto(0)

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:esxi_shell_time_out) do
    desc ""
    newvalues(/\d+/)
    defaultto(0)

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:esxi_shell_interactive_time_out) do
    desc ""
    newvalues(/\d+/)
    defaultto(0)

    munge do |value|
      Integer(value)
    end
  end

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:name]
  end
end
