Puppet::Type.newtype(:esx_get_iqns) do
  @doc = "Get availavle iqns from esx host."

  ensurable

  newparam(:host, :namevar => true) do
    desc "IP address or host name of ESX host where the datastore is attached to."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid name or IP of the host."
      end
    end
  end

  newparam(:hostusername) do
    desc "The ESX host's username."
  end
  newparam(:hostpassword) do
    desc "The ESX host's password."
  end

  newproperty(:get_esx_iqns) do
    desc "Get IQNS from server"
    newvalues(true,false)
    defaultto(true)
  end

end