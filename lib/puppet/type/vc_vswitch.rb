# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:vc_vswitch) do
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
  end

  newparam(:path) do
    desc "DC path"
  end

  newparam(:host) do
    desc "ESX host"
  end

  newparam(:num_ports) do
    desc "Num of ports"
  end

  newproperty(:nics, :array_matching => :all) do
    desc "nics to be attached to vSwitch"
    def insync?(is)
      self.devfail "#{self.class.name}'s should is not array" unless @should.is_a?(Array)

      # an empty array is analogous to no should values
      return (is == @should or is == @should.collect { |v| v.to_s }) if match_all?

      # Look for a matching value
      return true if @should.empty?

      @should.each { |val| return true if is == val or is == val.to_s }

      # otherwise, return false
      false
    end
  end

end
