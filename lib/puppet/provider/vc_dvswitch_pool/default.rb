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
      when :shares, :level
        config_spec.allocationInfo.shares ||= RbVmomi::VIM::SharesInfo.new
        config_spec.allocationInfo.shares[prop_sym] = value
      else
        config_spec[prop_sym] = value
      end
    end
  end

  def create
    @creating = true
    @create_message ||= []
    Puppet::Type.type(:vc_dvswitch_pool).properties.collect{|x| x.name }.each do |prop|
      unless (value = @resource[prop]).nil?
        self.send("#{prop}=".to_sym, value)
        @create_message << "#{prop} => #{value.inspect}"
      end 
    end
  end

  def create_message
    @create_message ||= []
    "created using {#{@create_message.join ", "}}"
  end

  def destroy
    dvswitch.RemoveNetworkResourcePool( :key => [resource_pool.key] )
  end

  def exists?
    resource_pool
  end

  def flush
    if @flush_required
      if @creating
        dvswitch.AddNetworkResourcePool(:configSpec => [config_spec])
      else
        dvswitch.UpdateNetworkResourcePool(:configSpec => [config_spec])
      end
    end
  end

  alias set_level level=
  # Override level= to include setting the shares based off Enum SharesInfo http://pubs.vmware.com/vsphere-55/index.jsp#com.vmware.wssdk.apiref.doc/vim.SharesInfo.Level.html
  def level=(value)
    @flush_required = true
    self.set_level value.to_s
    case value
    when :high
      num_shares = networkResourcePoolHighShareValue
    when :normal
      num_shares = networkResourcePoolHighShareValue * 0.5
    when :low
      num_shares = networkResourcePoolHighShareValue * 0.25
    when :custom
      raise Puppet::Error, "#{resource.inspect} must include property 'shares' when setting 'level' to 'custom'" unless resource[:shares]
      num_shares=resource[:shares]
    end
    self.shares=num_shares.to_i
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
      if resource_pool
        spec.name = resource_pool.name.dup
        spec.key = resource_pool.key.dup
        spec.description = resource_pool.description.dup if resource_pool.description
        spec.allocationInfo = resource_pool.allocationInfo.dup
        spec.allocationInfo.shares = resource_pool.allocationInfo.shares.dup
        spec.allocationInfo.shares.level = resource_pool.allocationInfo.shares.level.dup
      else
        spec.name = resource[:key]
        spec.key  = resource[:key]
        spec.allocationInfo = RbVmomi::VIM::DVSNetworkResourcePoolAllocationInfo.new if resource[:limit] || resource[:priority_tag] || resource[:shares] || resources[:level]
      end
      spec
    end
  end

  def networkResourcePoolHighShareValue
    @DvsFeatureCapability ||= vim.serviceContent.dvSwitchManager.QueryDvsFeatureCapability( :switchProductSpec => dvswitch.config.productInfo )
    @DvsFeatureCapability.networkResourcePoolHighShareValue
  end
 
  def resource_pool
    @resource_pool ||= dvswitch.networkResourcePool.find{|nrp| nrp.key == @resource[:key] || nrp.name == @resource[:key]}
  end

end
