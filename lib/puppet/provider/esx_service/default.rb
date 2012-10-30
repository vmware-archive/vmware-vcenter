require 'lib/puppet/provider/vcenter'

Puppet::Type.type(:esx_service).provide(:esx_service, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter hosts service."

  def restart
    if host.config.service.service.find{|x| x.key == resource[:service]}.running
      host.configManager.serviceSystem.RestartService(:id => resource[:service])
    else
      Puppet.debug "ESX service #{resource[:service]} is not running."
    end
  end

  def running
    service = host.config.service.service.find{|x| x.key == resource[:service]}
    service.running ? :true : :false
  end

  def running=(value)
    if value == :true
      host.configManager.serviceSystem.StartService(:id => resource[:service])
    else
      host.configManager.serviceSystem.StopService(:id => resource[:service])
    end
  end

  def policy
    service = host.config.service.service.find{|x| x.key == resource[:service]}
    service.policy if service
  end

  def policy=(value)
    # TODO:
  end

  private

  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
  end
end

