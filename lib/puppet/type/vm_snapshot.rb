# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:vm_snapshot) do
  @doc = "Manage vCenter VMs Snapshot Operation."

  ensurable do
    newvalue(:present) do
        provider.create
    end
    newvalue(:absent) do
        provider.destroy
    end
    defaultto(:present)
  end

  newparam(:name, :namevar => true) do
    desc "The virtual machine name."
  end

  newparam(:snapshot_name) do 
    desc "Name of the snapshot."
  end
  
  newproperty (:snapshot_operation)do
    newvalues(:revert, :remove)
  end

  newparam(:datacenter) do 
    desc "Name of the datacenter."
  end

end

