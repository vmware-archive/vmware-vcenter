# Copyright (C) 2013 VMware, Inc.

provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_dnsconfig).provide(:esx_dnsconfig, :parent => Puppet::Provider::Vcenter) do
  @doc = "This resource allows disabling dhcp for DNS, and setting DNS client parameters"

  Puppet::Type.type(:esx_dnsconfig).properties.collect{|x| x.name}.each do |prop|

    prop_sym = PuppetX::VMware::Util.camelize(prop, :lower).to_sym
 
    define_method(prop) do
      case value = host.config.network.dnsConfig[prop_sym]
        when TrueClass then :true
        when FalseClass then :false
        else value
      end
    end

    define_method("#{prop}=") do |value|
      hostDnsConfig[prop_sym]= value
      @pending_changes = true
    end
  end

  def flush
    if @pending_changes
      host.configManager.networkSystem.UpdateDnsConfig(:config => @host_dns)
    end
  end

  private
 
  def hostDnsConfig
    @host_dns ||= {}.merge(host.config.network.dnsConfig.props)
  end

  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
  end

end
