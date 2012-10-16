require 'lib/puppet/provider/vcsa'

Puppet::Type.type(:vcsa_eula).provide(:vcsa_eula, :parent => Puppet::Provider::Vcsa ) do
  @doc = 'Manages vCSA EULA'

  def accept
    transport.send('vpxd_servicecfg eula accept')
  end

  def exists?
    transport.send('vpxd_servicecfg eula read')
    result = Hash[*transport.result.split("\n").collect{|x| x.split('=')}.flatten]
    result['VC_EULA_STATUS'] != "0"
  end
end

