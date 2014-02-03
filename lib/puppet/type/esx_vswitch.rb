# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_vswitch) do
  @doc = "Manage vCenter vSwitch."

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
    desc "ESX host:vSwitch name."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid ESX host:vSwitch name."
      end
    end
    munge do |value|
      @resource[:host], @resource[:vswitch] = value.split(':',2)
      value
    end
  end

  newparam(:path) do
    desc "Datacenter path where host resides"
    validate do |path|
      raise ArgumentError, "Absolute path is required: #{path}" unless Puppet::Util.absolute_path?(path)
    end
  end

  newparam(:vswitch) do
    desc "The name of vSwitch"
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid vSwitch name."
      end
    end
  end

  newparam(:host) do
    desc "ESX hostname or IP"
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid host name."
      end
    end
  end

  newproperty(:num_ports) do
    desc "The number of ports that this virtual switch is configured to use. The maximum value is 4088"
    dvalue = '128'
    defaultto(dvalue)    
    munge do |value|
      if value.to_i == 0
        dvalue.to_i
      else
        value.to_i + 8
      end
    end
  end

  newproperty(:nics, :array_matching => :all) do
    desc "The list of keys of the physical network adapters to be bridged to vSwitch"
    def insync?(is)
      self.devfail "#{self.class.name}'s should is not array" unless @should.is_a?(Array)

      # Look for a matching value
      return (is == @should or is == @should.collect { |v| v.to_s }) if match_all?

      # an empty array is analogous to no should values
      return true if @should.empty?

      @should.each { |val| return true if is == val or is == val.to_s }

      # otherwise, return false
      false
    end
  end

  newproperty(:nicorderpolicy) do
    desc "Failover order policy for network adapters on this switch."
  end

  newproperty(:mtu) do
    desc "The maximum transmission unit (MTU) of the virtual switch in bytes."
    dvalue = '1500'
    defaultto(dvalue)
    validate do |value|
      raise ArgumentError, "mtu must be in range 1500 - 9000." if (value.to_i<1500 || value.to_i > 9000)
    end
    munge do |value|
      if value.to_i == 0
        dvalue.to_i
      else
        value.to_i
      end
    end
  end

  newproperty(:checkbeacon) do
    desc "The flag to indicate whether or not to enable beacon probing as a method to validate the link status of a physical network adapter."
    newvalues(:true, :false)
    defaultto(:true)
  end

end
