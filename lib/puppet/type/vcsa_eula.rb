Puppet::Type.newtype(:vcsa_eula) do
  @doc = 'Manage vCSA EULA.'

  ensurable do
    newvalue(:present) do
      provider.accept
    end

    aliasvalue(:accept, :present)
  end

  newparam(:name, :namevar => true) do
  end

  newparam(:transport) do
    desc 'Reference the appropriate vCSA transport resource.'
  end
end
