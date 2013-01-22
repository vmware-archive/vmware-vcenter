provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_timezone).provide(:esx_timezone, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter hosts timezone configuration."

  def key
    host.config.dateTimeInfo.timeZone.key
  end

  def key=(value)
    dtconfig = { :timeZone => value }
    host.configManager.dateTimeSystem.UpdateDateTimeConfig(:config => dtconfig)
  end

  private

  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
  end
end

