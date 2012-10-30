require 'lib/puppet/provider/vcenter'

Puppet::Type.type(:esx_debug).provide(:esx_ntpconfig, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter hosts ntp configuration."

  def debug
    require 'ruby-debug'
    debugger
    host
  end

  private

  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
  end
end

