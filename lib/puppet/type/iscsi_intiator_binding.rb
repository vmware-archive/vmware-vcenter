Puppet::Type.newtype(:iscsi_intiator_binding) do
  @doc = "Binding the HBA to VMKernal nic."

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
    desc "ESX host name:hba name."

    munge do |value|
      @resource[:host_name], @resource[:vmhba] = value.split(':',2)
      value
    end
  end

  newparam(:vmhba) do
    desc "The name of the vm hba."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid name of the HBA."
      end
    end
  end

  newparam(:host_name) do
    desc "The ESX host name."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid name or IP of the host."
      end
    end
  end

  newparam(:host_username) do
    desc "ESX username."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid username."
      end
    end
  end

  newparam(:host_password) do
    desc "ESX password."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid password."
      end
    end
  end

  newparam(:script_executable_path) do
    desc "Script executable path."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid path."
      end
    end
  end

  newparam(:vmknics) do
    desc "VMKernal NICs to use for binding with iscsi VM HBA."
  end
end