Puppet::Type.newtype(:vc_vsan_disk_initialize) do
  @doc = "Initialize VSAN Disk for cluster nodes"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Resource name"
  end

  newparam(:cluster) do
    desc 'Name of the cluster.'
  end

  newparam(:datacenter) do
    desc 'Name of the cluster.'
  end

end
