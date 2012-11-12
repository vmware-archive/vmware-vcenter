require 'puppet/provider/vshield'

Puppet::Type.type(:vs_syslog).provide(:vs_syslog, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShild hosts syslog configuration.'

  def serverinfo
    begin
      result = get('services/syslog/config')
      result['syslogServerConfig']['serverInfo']
    rescue
      ''
    end
  end

  def serverinfo=(value)
    setting = { 'syslogServerConfig' =>
                { 'serverInfo' => value } }
    put('services/syslog/config', setting)
  end
end

