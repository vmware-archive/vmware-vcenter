# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:vc_portgroup) do
  @doc = "Manage vCenter VMs."

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
    desc "vSwitch port group name."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid port group name."
      end
    end

  end

  newproperty(:traffic_shaping_policy) do
    desc "Enable or Disable the traffic shaping policy on the vSwitch portgroup."
    newvalues(:Enabled, :Disabled)
  end

  newparam(:datacenter) do
    desc "Name of the datacenter."
        validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid datacenter name."
      end
    end
  end


  newparam(:vswitchname) do
    desc "Name of the vSwitch."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid vSwitch name."
      end
    end
  end

  newparam(:type) do
    desc "Type of port group."
    newvalues(:VirtualMachine, :VMkernel)
    dvalue="VirtualMachine"
    defaultto(dvalue)
  end

  newparam (:averagebandwidth) do
    desc "Average bandwidth."
    dvalue = 1000
    defaultto(dvalue)
  end

  newparam (:peakbandwidth) do
    desc "Peak bandwidth."
    dvalue = 1000
    defaultto(dvalue)
  end

  newparam (:burstsize) do
    desc "Burst size."
    dvalue = 1024
    defaultto(dvalue)
  end

  newproperty (:vmotion) do
    desc "Enable or Disable the vmotion on the VMkernel portgroup."
    newvalues(:true, :false)
  end
  
  newproperty (:ipconfig) do
    desc "IP settings on the VMkernel port group."
    newvalues(:automatic, :manual)
  end

  newparam(:ipaddress) do
    desc "IP address of VMkernel port group."
  end

  newparam (:subnetmask) do
    desc "Subnet mask of VMkernel port group."
  end

  newparam(:path) do
    desc "The path to the host."
    validate do |path|
      raise ArgumentError, "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(path)
    end
  end

  newparam(:host) do
    desc "The Host IP."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid host name."
      end
    end
  end

  newproperty(:vlanid) do
    desc "VLAN id."
	validate do |vlanid|
	  raise ArgumentError, "VLAN id must be in between 0 and 4095." if (vlanid.to_i<0 || vlanid.to_i > 4095)
	end
    defaultto 0
  end

end
