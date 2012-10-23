Puppet::Type.newtype(:vcsa_db) do
  @doc = 'Manage vCSA db.'

  ensurable

  newparam(:name, :namevar => true) do
  end

  newparam(:type) do
    desc 'vCSA database type.'
  end

  newparam(:server) do
    desc 'vCSA database server.'
  end

  newparam(:port) do
    desc 'vCSA database port.'
  end

  newparam(:instance) do
    desc 'vCSA database instance.'
  end

  newparam(:user) do
    desc 'vCSA database user.'
  end

  newparam(:password) do
    desc 'vCSA database password.'
  end
end
