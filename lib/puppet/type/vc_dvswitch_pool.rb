# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:vc_dvswitch_pool) do
  @doc = "Manages vCenter Distributed Virtual Switch "\
         "Network Resource Pool Management"

  ensurable do
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar => true) do
    desc "{path to dvswitch}:{network resource pool key}"

    munge do |value|
      @resource[:dvswitch_path], @resource[:key] = value.split(':',2)
      value
    end
  end

  newparam(:dvswitch_path) do
    desc "The path to the dvportgroup."
    validate do |value|
      raise "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(value)
    end
    munge do |value|
      @resource[:dvswitch_name] = value.split('/')[-1]
      value
    end
  end

  newparam(:dvswitch_name) do
  end

  newparam(:key) do
    desc "pool identifier"
  end

  newproperty(:description) do
    desc "A string describing the network resource pool"
  end

  newproperty(:limit) do
    desc "Maximum allowed usage for network clients belonging to this resource pool per host. To set to Unlimited set this to -1"
  end

  newproperty(:priority_tag) do
    desc "QOS priority tag"
  end

  newproperty(:shares) do
    desc "network shares"
  end

  newproperty(:level) do
    desc "Share level ('custom', 'high', 'low', 'normal')"
    newvalues(:custom, :high, :low, :normal)
  end

  # autorequire datacenter
  autorequire(:vc_dvswitch) do
    self[:dvswitch_path]
  end

end
