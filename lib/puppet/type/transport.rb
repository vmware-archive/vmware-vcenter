Puppet::Type.newtype(:transport) do
  @doc = "Manage transport connectivity info such as username, password, server."

  newparam(:name, :namevar => true) do
    desc "The name of the network transport."
  end

  newparam(:username) do
  end

  newparam(:password) do
  end

  newparam(:server) do
  end
end
