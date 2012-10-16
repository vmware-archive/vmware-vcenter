Puppet::Type.newtype(:vcsa_transport) do
  @doc = "Manage vCSA transport connectivity info."

  newparam(:name, :namevar => true) do
    desc "The name of the vcsa transport."
  end

  newparam(:username) do
  end

  newparam(:password) do
  end

  newparam(:server) do
  end
end
