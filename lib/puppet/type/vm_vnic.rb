Puppet::Type.newtype(:vm_vnic) do
  @doc = "Manage VM's vNic configuration."

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
    desc "Name of the vNIC."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid vNIC specified."
      end
    end
  end

  newproperty (:portgroup)do
    desc "Name of the port group to which the vNIC is to be attached."
    validate do |value|
          if value.strip.length == 0
            raise ArgumentError, "Invalid portgroup specified."
          end
    end
  end

  newparam(:vm_name) do
    desc "Name of the virtual machine."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid vm_name specified."
      end
    end
  end

  newparam(:datacenter) do
    desc "Name of the datacenter."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid datacenter specified."
      end
    end
  end

  newparam(:nic_type) do
    desc "vNIC type to be created."
    newvalues(:"VMXNET 2", :E1000, :"VMXNET 3")
    defaultto(:E1000)
  end

end