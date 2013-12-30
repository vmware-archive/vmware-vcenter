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
    desc "Virtual Switch port group name."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid vSwitch name."
      end
    end
  end

  newparam(:path) do
    desc "DC path"
    validate do |path|
      raise ArgumentError, "Absolute path is required: #{path}" unless Puppet::Util.absolute_path?(path)
    end
  end

  newparam(:host) do
    desc "ESX host"
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid host name."
      end
    end
  end

  newproperty(:num_ports) do
    desc "Num of ports"
    dvalue = '120'
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
    desc "nics to be attached to vSwitch"
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
    desc "nic order ploicy to be applied to vSwitch"
  end

  newproperty(:mtu) do
    desc "MTU"
    dvalue = '1500'
    defaultto(dvalue)
    munge do |value|
      if value.to_i == 0
        dvalue.to_i
      else
        value.to_i
      end
    end
  end

  newproperty(:checkbeacon) do
    newvalues(:true, :false)
    desc "The flag to indicate whether or not to enable beacon probing as a method to validate the link status of a physical network adapter."
    defaultto(:true)
  end

end
