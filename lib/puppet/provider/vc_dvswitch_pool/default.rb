# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vc_dvswitch_pool).provide(:vc_dvswitch_pool, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manage dvSwitch network resource pools"

  Puppet::Type.type(:vc_dvswitch_pool).properties.collect{|x| x.name}.each do |prop|

    prop_sym = PuppetX::VMware::Util.camelize(prop, :lower).to_sym

    define_method(prop) do
      case prop_sym
      when :limit, :priorityTag
        resource_pool.allocationInfo[prop_sym].to_s
      when :shares, :level
        resource_pool.allocationInfo.shares[prop_sym].to_s
      else
        resource_pool[prop_sym].to_s
      end
    end

    define_method("#{prop}=") do |value|
      @flush_required = true
      case prop_sym
      when :limit, :priorityTag
        config_spec.allocationInfo[prop_sym] = value
      when :shares
        config_spec.allocationInfo.shares[prop_sym] = value
      when :level
        config_spec.allocationInfo.shares[prop_sym] = RbVmomi::VIM::SharesLevel.new(value.to_sym)
      else
        config_spec[prop_sym] = value
      end
    end
  end

  def flush
    if @flush_required
      dvswitch.UpdateNetworkResourcePool(:configSpec => [config_spec])
    end
  end

  private

  def dvswitch
    @dvswitch ||= begin
      dc = vim.serviceInstance.find_datacenter(parent(@resource[:dvswitch_path]))
      dvswitches = dc.networkFolder.children.select {|n|
        n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch
      }
      dvswitches.find{|d| d.name == @resource[:dvswitch_name]}
    end
    fail "dvswitch not found." unless @dvswitch
    @dvswitch
  end

  # Creates a new DVSNetworkResourcePoolConfigSpec populated with existing parameters
  def config_spec
    @config_spec ||= begin
      spec = RbVmomi::VIM::DVSNetworkResourcePoolConfigSpec.new
      spec.name = resource_pool.name.dup
      spec.key = resource_pool.key.dup
      spec.description = resource_pool.description.dup
      spec.allocationInfo = resource_pool.allocationInfo.dup
      spec.allocationInfo.shares = resource_pool.allocationInfo.shares.dup
      spec.allocationInfo.shares.level = resource_pool.allocationInfo.shares.level.dup
      spec
    end
  end

  def resource_pool
    @resource_pool ||= dvswitch.networkResourcePool.find{|nrp| nrp.key == @resource[:key]}
    fail "resource pool #{@resource[:key]} not found." unless @resource_pool
    @resource_pool
  end

end
