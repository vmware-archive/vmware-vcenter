# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_portgroup) do
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
    desc "vSwitch portgroup name."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid vSwitch portgroup name."
      end
    end
    munge do |value|
      @resource[:host], @resource[:portgrp] = value.split(':',2)
     value
    end

  end
  
  newparam(:portgrp) do
    desc "The name of portgroup."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid portgroup name."
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

  newparam(:vswitch) do
    desc "Name of the vSwitch."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid vSwitch name."
      end
    end
  end

  newparam(:path) do
    desc "The path to the host."
    validate do |path|
      raise ArgumentError, "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(path)
    end
  end

  newparam(:host) do
    desc "The Host IP/hostname."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid host name."
      end
    end
  end

  newparam(:nicorderpolicy) do
    desc "nic order ploicy to be applied to vSwitch"
  end

  newparam(:portgrouptype) do
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

  newparam(:ipaddress) do
    desc "IP address of VMkernel port group."
  end

  newparam (:subnetmask) do
    desc "Subnet mask of VMkernel port group."
  end

  newproperty(:traffic_shaping_policy) do
    desc "Enable or Disable the traffic shaping policy on the vSwitch portgroup."
    newvalues(:enabled, :disabled)
  end

  newparam(:checkbeacon) do
    newvalues(:true, :false)
    desc "Value of checkbeacon flag."
  end

  newparam(:failback) do
    newvalues(:true, :false)
    desc "Value of failback flag."
    #defaultto(:false)
  end

  newproperty(:mtu) do
    desc "mtu size used for jumbo frames."
    validate do |value|
      raise ArgumentError, "mtu must be in between 1500 and 9000." if (value.to_i<1500 || value.to_i > 9000)
      if value.to_s.strip.length == 0
        raise ArgumentError, "Invalid mtu."
      end
    end
  end

  newproperty(:overridefailoverorder) do
    desc "flag to indicate the failover policy is to be overridden or not"
    newvalues(:enabled,:disabled)
  end

  newproperty(:overridecheckbeacon) do
    newvalues(:enabled, :disabled)
    desc "The flag to indicate whether or not to enable beacon probing as a method to validate the link status of a physical network adapter."
  end

   newproperty(:overridefailback) do
    newvalues(:enabled, :disabled)
    desc "The flag to indicate whether or not to enable beacon probing as a method to validate the link status of a physical network adapter."
  end

  newproperty (:vmotion) do
    desc "Enable or Disable the vmotion on the VMkernel portgroup."
    newvalues(:enabled, :disabled)
  end

  newproperty (:ipsettings) do
    desc "IP settings on the VMkernel port group."
    newvalues(:dhcp, :static)
  end

  newproperty(:vlanid) do
    desc "VLAN id."
    dvalue = 0
    defaultto(dvalue)
    validate do |vlanid|
      raise ArgumentError, "VLAN id must be in between 0 and 4095." if (vlanid.to_i<0 || vlanid.to_i > 4095)
        intval = vlanid.to_i
        if (intval.to_s != vlanid.to_s)
                raise ArgumentError, "VLAN id must be in between 0 and 4095."
        end	  
    end
  end
end
