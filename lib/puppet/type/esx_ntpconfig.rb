Puppet::Type.newtype(:esx_ntpconfig) do
  @doc = "Manage vCenter esx hosts config datetimeinfo ntpconfig."

  newparam(:name, :namevar => true) do
    desc "ESX hostname or ip address."
  end

  newproperty(:server,:array_matching => :all) do
    desc "ntp server"
    defaultto([])
    munge do |value|
      [value] unless value.is_a? Array
    end
  end

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:name]
  end
end
