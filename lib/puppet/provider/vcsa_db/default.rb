require 'lib/puppet/provider/vcsa'

Puppet::Type.type(:vcsa_db).provide(:vcsa_db, :parent => Puppet::Provider::Vcsa ) do
  @doc = 'Manages vCSA db'

  def create
    transport.send("vpxd_servicecfg db write #{resource[:type]}")
  end

  def exists?
    transport.send('vpxd_servicecfg db read')
    result = Hash[*transport.result.split("\n").collect{|x| x.split('=',2)}.flatten]
    result['VC_DB_TYPE'] != ''
  end
end
