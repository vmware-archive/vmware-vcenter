# Copyright 2014 VMware, Inc.

provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_powerpolicy).provide(:esx_powerpolicy, :parent => Puppet::Provider::Vcenter) do
  @doc = "This resource allows for updating the power policy for ESX hosts."

  Puppet::Type.type(:esx_powerpolicy).properties.collect{|x| x.name}.each do |prop|

    prop_sym = PuppetX::VMware::Util.camelize(prop, :lower).to_sym
 
    define_method(prop) do
      case value = host.configManager.powerSystem.info.currentPolicy.shortName
        when TrueClass then :true
        when FalseClass then :false
        else value
      end
    end

    define_method("#{prop}=") do |value|
      @short_name = value
      @pending_changes = true
    end
  end

  def flush
    if @pending_changes
      host.configManager.powerSystem.ConfigurePowerPolicy(:key => powerPolicyKeyLookup)
    end
  end

  private
 
  def powerPolicyKeyLookup
    host.configManager.powerSystem.capability.availablePolicy.find do |policy|
      policy.shortName == @short_name.to_s
    end.key
  end

  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
  end

end
