# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_iscsi_options).provide(:esx_iscsi_options, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter hosts' iscsi advanced options."

  def initialize(args)
    @changed_keys = []

    super(args)
  end

  def options
    value = {}
    Puppet.debug("Options: #{resource[:options]}")

    resource[:options].keys.each do |optkey|
      v = (hba.advancedOptions.map { |x| v = x[:value] if x[:key] == optkey } || []).compact[0]
      v = v.to_s if Integer === v
      value[optkey] = v
      @changed_keys.push(optkey) if v != resource[:options][optkey]
    end
    value
  rescue RbVmomi::Fault
    Puppet.debug "ESX advanced options #{resource[:options]} -- get failed for " +
        "key '#{optkey}'"
    fail "property '#{optkey}' not found in map"
  end

  def options=(value)
    changedValue = []
    @changed_keys.each do |optkey|
      optvalue = cast_option(optkey, value[optkey])
      changedValue.push({:key => optkey, :value => optvalue})
    end

    changedValue.each do |change|
      options = []
      options[0] = RbVmomi::VIM.HostInternetScsiHbaParamValue
      options[0].key = change[:key]
      options[0].value = change[:value]
      host.configManager.storageSystem.UpdateInternetScsiAdvancedOptions({:iScsiHbaDevice => @resource[:iscsi_hba_device],:options => options})
    end

  end

  private

  def cast_option(key, value)
    optdef = @hba.supportedAdvancedOptions.find{|so| so[:key] == key}
    case optdef.optionType.class.to_s
      when "IntOption"
        Puppet.debug("Inside Int loop")
        value = RbVmomi::BasicTypes::Int.new value.to_i
      when "LongOption"
        value.to_i
      else
        Puppet.debug("Inside default loop")
        value
    end
    value
  end

  def esxhost
    Puppet.debug("ESXHost: #{@resource[:esx_host]}")
    host(@resource[:esx_host])
  end

  def hba
    @hba ||= esxhost.configManager.storageSystem.storageDeviceInfo.hostBusAdapter.find{|a|
      a.device == resource[:iscsi_hba_device]}
  end

end

