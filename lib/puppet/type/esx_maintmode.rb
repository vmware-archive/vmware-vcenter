# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_maintmode) do
  @doc = "Manage Host system enter / exit maintenance mode."

  ensurable do
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:hostseq, :namevar => true) do
    desc "ESX hostname and optional sequence number.  format: host:seq"

    munge do |value|
      @resource[:host] = value.split(':',2)[0]
      value
    end
  end

  newparam(:host) do
    desc "ESX hostname"
  end

  newparam(:timeout) do
    desc "Timeout on maintenance mode operations.  Defaults to 0 (no timeout)."
    newvalues(/\d+/)
    defaultto(0)

    munge do |value|
      Integer(value)
    end
  end

  newparam(:evacuate_powered_off_vms) do
    desc "Only supported by vcenter.  "\
         "If true, this will use DRS to migrate off powered down VMs before"\
         " completing the operation"
    newvalues(:true, :false)
    defaultto(:false)
    #
    # The provider must accept and return Symbols :true and
    # :false, not TrueClass nor FalseClass. Methods is_to_s and
    # should_to_s clarify messages like 'changed true to true'
    # that would result from provider bugs.
    #
    def is_to_s(v)
      v.inspect
    end

    def should_to_s(v)
      v.inspect
    end
  end
end