# Copyright (C) 2014 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_system_resource).provide(:esx_system_resource, :parent => Puppet::Provider::Vcenter) do

  Puppet::Type.type(:esx_system_resource).properties.collect{|x| x.name}.each do |prop|
    str_prop = prop.to_s
    type = str_prop.split('_')[0]
    camel_prop = PuppetX::VMware::Util.camelize(str_prop.sub("#{type}_",''), :lower).to_sym

    define_method(prop) do
      value = systemResource.config.method("#{type}Allocation").call[camel_prop]
      case value
      when TrueClass then :true
      when FalseClass then :false
      else value.to_s
      end
    end

    define_method("#{prop}=") do |value|
      @update = true
      systemResource.config.method("#{type}Allocation").call[camel_prop] = value
    end
  end

  def flush
    if @update
      host.UpdateSystemResources(:resourceInfo => systemResource)
    end
  end

  def findSystemResource (systemResources)
    if systemResources.key.split('/')[-1] == resource[:system_resource]
      Puppet.debug "System Resource found: #{systemResources.key}"
      @foundSystemResource = systemResources
    else
      systemResources.child.each do |child|
        findSystemResource(child)
      end
    end
  end

  def managedSystemResource
    findSystemResource(host.systemResources)
    @managedSystemResource = @foundSystemResource or raise Puppet::Error "Unable to locate host system resource #{resource[:system_resource]} on host #{resource[:host]}"
  end

  def systemResource
    @systemResource ||= managedSystemResource
  end

  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false) or raise Puppet::Error, "Host '#{resource[:host]}' not found"
  end
end
