Puppet::Type.newtype(:transport) do
  @doc = "Manage transport connectivity info."

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
