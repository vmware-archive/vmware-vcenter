Puppet::Type.newtype(:esx_debug) do
  @doc = "Puppet debug tool."

  newparam(:host, :namevar => true) do
    desc "ESX host name."

  end

  newproperty(:debug) do
  end

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:name]
  end
end
