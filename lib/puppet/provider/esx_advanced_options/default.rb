# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_advanced_options).provide(:esx_advanced_options, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter hosts' advanced options."

  def initialize(args)
    @changed_keys = []

    super(args)
  end

  def options
    value = {}
    property = nil

    resource[:options].keys.each do |optkey|

      property = optkey
      v = host.configManager.advancedOption.QueryOptions(:name => optkey)[0].value
      v = v.to_s if Integer === v
      value[optkey] = v
      @changed_keys.push(optkey) if v != resource[:options][optkey]
    end
    value
  rescue RbVmomi::Fault
    Puppet.debug "ESX advanced options %s -- get failed for key %s " % [resource[:options], property]
    fail "property %s not found in map" % property
  end

  def options=(value)
    changedValue = []
    @changed_keys.each do |optkey|
      optvalue = cast_option(optkey, value[optkey])
      changedValue.push({:key => optkey, :value => optvalue})
    end
    host.configManager.advancedOption.UpdateOptions(:changedValue => changedValue) if changedValue != []
  end

  private

  def cast_option(key, value)
    optdef = host.configManager.advancedOption.supportedOption.find{|so| so[:key] == key}
    return value.to_i if optdef.nil?
    case optdef.optionType.class.to_s
    when "IntOption"
      RbVmomi::BasicTypes::Int.new value.to_i
    when "LongOption"
      value.to_i
    else
      value
    end
  end

end
