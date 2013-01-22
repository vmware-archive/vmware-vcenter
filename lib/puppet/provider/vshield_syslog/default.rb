provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vshield')

Puppet::Type.type(:vshield_syslog).provide(:vs_syslog, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShield hosts syslog configuration.'

  def server_info
    result = get('api/2.0/services/syslog/config')
    nested_value(result, ['syslogServerConfig', 'serverInfo'], 'not defined.')
  end

  def server_info=(value)
    setting = { 'syslogServerConfig' =>
                { 'serverInfo' => value } }
    put('api/2.0/services/syslog/config', setting)
  end
end
