require 'puppet/provider/vshield'

Puppet::Type.type(:vshield_syslog).provide(:vs_syslog, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShield hosts syslog configuration.'

  def server_info
    result = get('api/2.0/services/syslog/config') || []
    result['syslogServerConfig']['serverInfo']
  end

  def server_info=(value)
    setting = { 'syslogServerConfig' =>
                { 'serverInfo' => value } }
    put('api/2.0/services/syslog/config', setting)
  end
end
