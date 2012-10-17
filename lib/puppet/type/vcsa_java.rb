Puppet::Type.newtype(:vcsa_java) do
  @doc = 'Manage vCSA java max.'

  ensurable

  newparam(:name, :namevar => true) do
  end

  newproperty(:tomcat) do
    desc 'vCSA jmx tomcat'
    newvalues(/\d+/)
  end

  newproperty(:inventory) do
    desc 'vCSA jmx inventory service'
    newvalues(/\d+/)
  end

  newproperty(:sps) do
    desc 'vCSA jmx sps'
    newvalues(/\d+/)
  end

  newparam(:transport) do
    desc 'Reference the appropriate vCSA transport resource.'
  end
end
