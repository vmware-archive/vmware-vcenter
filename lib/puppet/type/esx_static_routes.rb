Puppet::Type.newtype(:esx_static_routes) do
  @doc = "Set static routes for ESX"

  ensurable do
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.destroy
    end
    defaultto(:present)
  end

  newparam(:host, :namevar => true) do
    desc "The Host IP/hostname."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid host name."
      end
    end
  end

  newparam(:gateways) do
    desc "Array of gateways for static routes"
    validate do |value|
      if value.is_a?(Array)
        value.each do |v|
          if !v.is_a?(String)
            raise ArgumentError, "Invalid type"
          end
        end
      else
        raise ArgumentError, "Invalid type"
      end
    end
  end

  newparam(:subnet_ip_addresses) do
    desc "Array of gateways for static routes"
    validate do |value|
      if value.is_a?(Array)
        value.each do |v|
          if !v.is_a?(String)
            raise ArgumentError, "Invalid type"
          end
        end
      else
        raise ArgumentError, "Invalid type"
      end
    end
  end

  autorequire(:vc_host) do
    self[:host]
  end
end
