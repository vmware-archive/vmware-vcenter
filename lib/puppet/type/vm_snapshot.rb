# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:vm_snapshot) do
  @doc = "Manage vCenter VMs Snapshot Operation."

  newparam(:name, :namevar => true) do
    desc "The name for this snapshot."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "%s is invalid snapshot name." % value
      end
    end
  end

  newparam(:memory_snapshot) do
    desc "Flag to create a memory dump of snapshot. If TRUE, a dump of the internal state of the virtual machine (basically a memory dump) is included in the snapshot"
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:snapshot_supress_power_on) do
    desc "snapshot_supress_power_on"
    newvalues(:true, :false)
    defaultto(:false)
  end

  newparam(:vm_name) do
    desc "The name of virtual machine."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "%s is invalid vm name." % value
      end
    end
  end

  newproperty (:snapshot_operation)do
    desc "Operation to create/remove/revert the snapshot."
    newvalues(:revert, :remove, :create)
  end

  newparam(:datacenter) do
    desc "Name of the datacenter."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "%s is invalid datacenter name." % value
      end
    end
  end

end

