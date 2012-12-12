Puppet::Type.newtype(:vc_cluster_evc) do
  @doc = "Manages vCenter cluster's settings for EVC (Enhanced Vmotion Compatibility)."

  newparam(:path, :namevar => true) do
    desc "The path to the cluster."

    validate do |value|
      raise "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(value)
    end
  end

  newproperty(:evc_mode_key) do
    desc "A string corresponding to the desired EVC Mode; or 'disabled' to disable EVC"
    defaultto(:disabled)

    munge do |value|
      value = value.to_sym
    end

  end

  # autorequire cluster - same path used for cluster configuration resources
  autorequire(:vc_cluster) do
    Pathname.new(self[:path]).to_s
  end

end
