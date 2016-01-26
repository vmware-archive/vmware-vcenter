Puppet::Type.newtype(:vc_vsan) do
  @doc = "Enable / Disable Cluster VSAN property."

  ensurable

  newparam(:name, :namevar => true) do
    desc "VSAN Resource title"
  end

  newparam(:auto_claim) do
    desc "Manage auto_claim property."
  end

  newparam(:cluster) do
    desc 'Name of the cluster.'
  end

  newparam(:datacenter) do
    desc 'Name of the cluster.'
  end

end
