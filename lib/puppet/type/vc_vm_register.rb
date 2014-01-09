Puppet::Type.newtype(:vc_vm_register) do
  @doc = "Register/Unregister vCenter VMs."

  ensurable

  newparam(:name, :namevar => true) do
    desc "Name by which the virtual machine is to be registered, or which has to be unregistered."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid name of virtual machine."
      end
    end
  end

  newparam(:datacenter) do
    desc "Name of the datacenter."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid datacenter name."
      end
    end
  end

  newparam(:hostip) do
    desc "Name of the host on which to register the vitual machine."
  end

  newparam(:astemplate) do
    desc "Flag to specify whether while registering virtual machine should be marked as a template."
    newvalues(:true,:false)
    defaultto(:false)
  end

  newparam(:vmpath_ondatastore) do
    desc "A datastore path to the virtual machine to be registered."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid vmpath_ondatastore."
      end
    end
  end

end