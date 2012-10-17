require 'lib/puppet/provider/vcsa'

Puppet::Type.type(:vcsa_service).provide(:vcsa_service, :parent => Puppet::Provider::Vcsa ) do
  @doc = 'Manages vCSA service'

  def create
    transport.send('vpxd_servicecfg service start')
  end

  def destroy
    transport.send('vpxd_servicecfg service stop')
  end

  def exists?
    transport.send('vpxd_servicecfg service status')
    result = Hash[*transport.result.split("\n").collect{|x| x.split('=',2)}.flatten]
    result['VC_SERVICE_STATUS'] != '0'
  end
end
