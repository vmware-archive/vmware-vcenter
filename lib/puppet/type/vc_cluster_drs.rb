# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:vc_cluster_drs) do
  @doc = "Manages vCenter cluster's settings for DRS (Distributed Resource Scheduler)."

  newparam(:path, :namevar => true) do
    desc "The path to the cluster."

    validate do |value|
      raise "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(value)
    end
  end

  newproperty(:enabled) do
   desc "Is DRS enabled? true or false"
   newvalues(:true, :false)
  end

  newproperty(:enable_vm_behavior_overrides) do
   desc "Is VM-specific override of cluster-wide DRS behavior enabled? true or false"
   newvalues(:true, :false)
  end

  newproperty(:default_vm_behavior) do
   desc "Cluster-wide default for DRS management of VMs: fullyAutomated, partiallyAutomated, or manual"
   newvalues(:fullyAutomated, :partiallyAutomated, :manual)
   munge do |value| value.to_sym end
  end

  newproperty(:vmotion_rate) do
    desc "Aggressiveness of DRS actions or recommendations for vMotion: 1 (aggressive) through 5 (conservative)"
    newvalues(1, 2, 3, 4, 5)
    munge do |value| value.to_i end
  end

  # autorequire cluster - cluster's path is used for its cluster configuration resources
  autorequire(:vc_cluster) do
    Pathname.new(self[:path]).to_s
  end

end
