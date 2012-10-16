Puppet::Type.newtype(:vcsa_eula) do
  @doc = 'Manage vCSA EULA.'

  ensurable do
    newvalue(:accept) do
      provider.accept
    end

#    newvalue(:absent) do
#      provider.destroy
#    end
#
#    aliasvalue(:true, :accept)
#    aliasvalue(:false, :absent)
  end

  newparam(:name, :namevar => true) do
  end

  newparam(:transport) do
    desc 'Reference the appropriate vCSA transport resource.'
  end
end
