provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcsa')

Puppet::Type.type(:vcsa_db).provide(:vcsa_db, :parent => Puppet::Provider::Vcsa ) do
  @doc = 'Manages vCSA db'

  def create
    transport.exec!("vpxd_servicecfg db write #{resource[:type]}")
  end

  def exists?
    result = transport.exec!('vpxd_servicecfg db read')
    result = Hash[*result.split("\n").collect{|x| x.split('=',2)}.flatten]
    result['VC_DB_TYPE'] != ''
  end
end
