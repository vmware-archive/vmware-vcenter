Puppet::Type.newtype(:esx_service) do
  @doc = "Manage vCenter esx hosts service."

  newparam(:name, :namevar => true) do
    desc "ESX host:service name."

    munge do |value|
      @resource[:host], @resource[:service] = value.split(':',2)
      value
    end
  end

  newparam(:service) do
  end

  newparam(:host) do
  end

  newproperty(:running) do
    newvalues(:true, :false)
    defaultto(false)

    munge do |value|
      value
    end
  end

  newproperty(:policy) do
    newvalues(:off, :on, :automatic)
  end

  def refresh
    provider.restart
  end

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:name]
  end
end
