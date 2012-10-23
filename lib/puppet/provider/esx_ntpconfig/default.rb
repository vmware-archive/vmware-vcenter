require 'lib/puppet/provider/vcenter'

Puppet::Type.type(:esx_ntpconfig).provide(:esx_ntpconfig, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter hosts ntp configuration."

  def server
    require 'ruby-debug'; debugger
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
    @host ||= find_host
  end

  def find_host
    vim.searchIndex.FindByDnsName(:dnsName => resource[:name], :vmSearch => false)
  end
end

