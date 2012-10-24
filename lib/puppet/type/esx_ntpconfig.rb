Puppet::Type.newtype(:esx_ntpconfig) do
  @doc = "Manage vCenter esx hosts config datetimeinfo ntpconfig."

  newparam(:host, :namevar => true) do
    desc "ESX hostname or ip address."
  end

  newproperty(:server,:array_matching => :all) do
    desc "ntp server"
    defaultto([])
    munge do |value|
      case value
      when Array
        raise Puppet::Error, "ESX only accepts a single ntp server."
        value.first
      when String
        value
      else
        raise Puppet::Error, "Unknown ntp server value: #{value}"
      end
    end
  end

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:name]
  end
end
