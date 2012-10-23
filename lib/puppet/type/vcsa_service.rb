Puppet::Type.newtype(:vcsa_service) do
  @doc = 'Manage vCSA service.'

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    aliasvalue(:running, :present)
    aliasvalue(:stopped, :absent)
  end

  newparam(:name, :namevar => true) do
  end
end
