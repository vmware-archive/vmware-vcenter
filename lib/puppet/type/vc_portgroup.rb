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
    desc "Virtual Switch port group name."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid port group name."
      end
    end

  end

  newproperty(:traffic_shaping_policy) do
    desc "Traffic Shaping policy of the vm."
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
        raise ArgumentError, "Invalid vswitch name."
      end
    end
  end

  newparam(:type) do
  desc "type of port group"
  dvalue="VirtualMachine"
  defaultto(dvalue)
  end

  newparam (:averagebandwidth) do
  dvalue = 1000
  defaultto(dvalue)
  end

  newparam (:peakbandwidth) do
  dvalue = 1000
  defaultto(dvalue)
  end

  newparam (:burstsize) do
  dvalue = 1024
  defaultto(dvalue)
  end

  newproperty (:vmotion) do
  newvalues(:true, :false)
  end
  
  newproperty (:ipconfig) do
  newvalues(:automatic, :manual)
  end

  newparam(:ipaddress) do
  desc "ipAddress of kernel port group"  
  #validate do |value|
  #if value.strip.length == 0
  #	raise ArgumentError, "Invalid ipaddress of portgroup."
  #end
  #end
  end

  newparam (:subnetmask) do
  desc "subnet mask of kernel port group"
  #validate do |value|
  #if value.strip.length == 0
  #	raise ArgumentError, "Invalid subnet mask of portgroup."
  #end
  #end
  end

  newparam(:path) do
    desc "The path to the host."

    validate do |path|
      raise "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(path)
    end
  end

 newparam(:host) do
    desc "The Host IP."
 end

  newproperty(:vlanid) do
    desc "The numeric ID for the VLAN."
	validate do |vlanid|
		raise "vlanid must be in between 0 and 4095" if (vlanid.to_i<0 || vlanid.to_i > 4095)
	end
        defaultto 0
  end


end
