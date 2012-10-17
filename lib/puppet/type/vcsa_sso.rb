Puppet::Type.newtype(:vcsa_sso) do
  @doc = 'Manage vCSA sso.'

  ensurable

  newparam(:name, :namevar => true) do
  end

  newparam(:dbtype) do
    newvalues('oracle', 'PostgreSQL', 'embedded', 'vcdb')
  end

  newparam(:server) do
  end

  newparam(:port) do
  end

  newparam(:instance) do
  end

  newparam(:user) do
  end

  newparam(:password) do
  end

  newparam(:transport) do
    desc 'Reference the appropriate vCSA transport resource.'
  end
end

