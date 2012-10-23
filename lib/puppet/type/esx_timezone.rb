Puppet::Type.newtype(:esx_timezone) do
  @doc = "Manage vCenter esx hosts config datetimeinfo timezone."

  newparam(:name, :namevar => true) do
    desc "ESX hostname or ip address."
  end

  newproperty(:key) do
    desc "timezone key"

    defaultto('UTC')
  end

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:name]
  end
end
