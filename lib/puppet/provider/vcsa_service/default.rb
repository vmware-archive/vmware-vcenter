require File.join Pathname.new(__FILE__).parent.parent, 'vcsa'

Puppet::Type.type(:vcsa_service).provide(:vcsa_service, :parent => Puppet::Provider::Vcsa ) do
  @doc = 'Manages vCSA service'

  def create
    transport.exec!('vpxd_servicecfg service start')
  end

  def destroy
    transport.exec!('vpxd_servicecfg service stop')
  end

  def exists?
    result = transport.exec!('vpxd_servicecfg service status')
    result = Hash[*result.split("\n").collect{|x| x.split('=',2)}.flatten]
    result['VC_SERVICE_STATUS'] != '0'
  end
end
