Puppet::Type.newtype(:vc_vsan_health_performance) do
  @doc = "Enable / Disable Cluster VSAN health performance service."

  ensurable

  newparam(:name, :namevar => true) do
    desc "VSAN Resource title"
  end

  newparam(:cluster) do
    desc 'Name of the cluster.'
  end

  newparam(:datacenter) do
    desc 'Name of the cluster.'
  end

end
