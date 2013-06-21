# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'resolv'

Puppet::Type.type(:esx_service).provide(:esx_service, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter hosts service."

  def restart
    if svc.running
      host.configManager.serviceSystem.RestartService(:id => resource[:service])
    else
      Puppet.debug "ESX service #{resource[:name]} restart ignored - not running"
    end
  end

  def running
    value = svc.running ? :true : :false
    Puppet.debug "ESX service #{resource[:name]} -- get running = #{value.class} '#{value.inspect}'"
    value
  end

  def running=(value)
    Puppet.debug "ESX service #{resource[:name]} -- set running = #{value.class} '#{value.inspect}'"
    case value
    when :true
      host.configManager.serviceSystem.StartService(:id => resource[:service])
    when :false
      host.configManager.serviceSystem.StopService(:id => resource[:service])
    else
      fail "invalid input #{value.class} '#{value.inspect}'"
    end
  end

  def policy
    value = svc.policy
    Puppet.debug "ESX service #{resource[:name]} -- get policy = #{value.class} '#{value.inspect}'"
    value
  end

  def policy=(value)
    Puppet.debug "ESX service #{resource[:name]} -- set policy = #{value.class} '#{value.inspect}'"
    host.configManager.serviceSystem.UpdateServicePolicy(:id => resource[:service], :policy => value)
  end

  private

  def svc
    @svc ||= 
        host.config.service.service.find{|x| x.key == resource[:service]} || 
        fail("service #{resource[:service]} not found")
  end

  def host
    if resource[:host] =~ Resolv::IPv4::Regex
      @host ||= vim.searchIndex.FindByIp(:ip => resource[:host], :vmSearch => false)
     else
      @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
     end
  end
end

