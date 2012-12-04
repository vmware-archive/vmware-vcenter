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
    defaultto(:false)
    # 
    # The provider must accept and return Symbols :true and
    # :false, not TrueClass nor FalseClass. Methods is_to_s and
    # should_to_s clarify messages like 'changed true to true'
    # that would result from provider bugs.
    # 
    def is_to_s(v)
      v.inspect
    end
    def should_to_s(v)
      v.inspect
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
    self[:host]
  end
end
