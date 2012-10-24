require 'lib/puppet/provider/vcenter'

Puppet::Type.type(:esx_ntpconfig).provide(:esx_ntpconfig, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter hosts ntp configuration."

  def server
    host.config.dateTimeInfo.ntpConfig.server
  end

  def server=(value)
    dtconfig = {
      :ntpConfig => { :server => value }
    }
    host.configManager.dateTimeSystem.UpdateDateTimeConfig(:config => dtconfig)
  end

  private

  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:name], :vmSearch => false)
  end
end

