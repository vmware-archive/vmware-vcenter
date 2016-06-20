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

  newparam(:vsan_disk_group_creation_type) do
    desc 'VSAN disk group creation type'
    newvalues('hybrid', 'allFlash')
    defaultto('hybrid')
  end

  newparam(:cleanup_hosts) do
    desc 'Array of Hosts to be removed from VSAN '
  end

end
