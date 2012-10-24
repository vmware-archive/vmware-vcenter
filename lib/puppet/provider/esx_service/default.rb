require 'lib/puppet/provider/vcenter'

Puppet::Type.type(:esx_service).provide(:esx_service, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter hosts service."

  def restart
    require 'ruby-debug'; debugger
    if host.config.service.service.find{|x| x.key == resource[:service]}.running
      host.configManager.serviceSystem.RestartService(:id => resource[:service])
      host.configManager.serviceSystem.RefreshServices
    else
      Puppet.debug "ESX service #{resource[:service]} is not running."
    end
  end

  private

  def host

    puts @resource[:host]
    puts resource[:host]
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
  end
end

