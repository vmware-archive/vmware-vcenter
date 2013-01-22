provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

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
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
  end
end

