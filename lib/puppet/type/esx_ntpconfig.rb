Puppet::Type.newtype(:esx_ntpconfig) do
  @doc = "Manage vCenter esx hosts ntpconfig."

  newparam(:host, :namevar => true) do
    desc "ESX hostname or ip address."
  end

  newproperty(:server, :array_matching => :all) do
    desc "ntp server"
    defaultto([])
  end

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:name]
  end
end
