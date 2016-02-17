Puppet::Type.newtype(:vc_vsan_network) do
  @doc = "Enable / Disable VSAN property on VMKernel"

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

  newparam(:vsan_port_group_name) do
    desc 'Name of port group where vsan property needs to be enabled / disabled'
  end

  newparam(:vsan_dv_port_group_name) do
    desc 'Name of distributed port group where vsan property needs to be enabled / disabled'
  end

  newparam(:vsan_dv_switch_name) do
    desc 'Name of dv switch name where vsan property needs to be enabled / disabled'
  end

end
