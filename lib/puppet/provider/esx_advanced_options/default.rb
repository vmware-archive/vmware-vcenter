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
    missing = []
    resource[:options].keys.each do |optkey|
      begin
        v = optionManager.QueryOptions(:name => optkey)
      rescue RbVmomi::Fault => e
        Puppet.debug e.message
        # rbvmomi seems to have only one class of fault, so check message 
        # to see if this is the one we want to handle, reraise if it's not
        case e.message
        when /\AInvalidName:/
          missing.push optkey
        else
          raise e
        end
      else
        v = v[0].value
        v = v.to_s if Integer === v
        value[optkey] = v
        @changed_keys.push(optkey) if v != resource[:options][optkey]
      end
    end
    msg = "ESX options #{resource[:options]} -- keys not found: #{missing.inspect}"
    fail msg unless missing.empty?
    value
  end

  def options=(value)
    changedValue = []
    @changed_keys.each do |optkey|
      optvalue = cast_option(optkey, value[optkey])
      changedValue.push({:key => optkey, :value => optvalue})
    end
    optionManager.UpdateOptions(:changedValue => changedValue) if changedValue != []
  end

  private

  def cast_option(key, value)
    optdef = optionManager.supportedOption.find{|so| so[:key] == key}
    case optdef.optionType.class.to_s
    when "IntOption"
      RbVmomi::BasicTypes::Int.new value.to_i
    when "LongOption"
      value.to_i
    else
      value
    end
  end

  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false) ||
        fail("host #{resource[:host]} not found")
  end

  def optionManager
    @optionManager ||= host.configManager.advancedOption
  end

end

