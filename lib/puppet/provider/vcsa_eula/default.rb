provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcsa')

Puppet::Type.type(:vcsa_eula).provide(:vcsa_eula, :parent => Puppet::Provider::Vcsa ) do
  @doc = 'Manages vCSA EULA'

  def accept
    transport.exec!('vpxd_servicecfg eula accept')
  end

  def exists?
    result = transport.exec!('vpxd_servicecfg eula read')
    result = Hash[*result.split("\n").collect{|x| x.split('=')}.flatten]
    result['VC_EULA_STATUS'] != "0"
  end
end

