Puppet::Type.newtype(:esx_connection_wait) do
  @doc = "Wait for ESX host connection upto specified time-limit"

  ensurable

  newparam(:init_sleep) do
    desc "Initial window to wait before polling for connection state. Defaults to 180 seconds."
    newvalues(/\d+/)
    defaultto(180)

    munge do |value|
      Integer(value)
    end
  end

  newparam(:max_wait) do
    desc "Maximum time to wait. Defaults to 600 seconds."
    newvalues(/\d+/)
    defaultto(600)

    munge do |value|
      Integer(value)
    end
  end

  newparam(:host, :namevar => true) do
    desc "The ESX host"
    validate do |value|
      if value.nil? || value.strip.length == 0
        raise ArgumentError, "Invalid name or IP of the host."
      end
    end
  end

end
