# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vc_vpxsettings).provide(:vc_vpxsettings, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter vpxSettings"

  private

  def config
    @config ||= vim.serviceInstance.content.setting
  end

  def cur_vpx_value(prop_name)
    result = config.setting.find{|x| x[:key] == prop_name} 
    msg = "key: #{prop_name} was not found,
           1. browse to https://<vcenter>/mob/?moid=ServiceInstance&method=retrieveContent
           2. click on Invoke Method
           3. select VpxSettings and check if your property is listed as setting[#{prop_name}],
              ( this should exactly match whats inside setting[] )"
    raise Puppet::Error, "#{msg}" if result.nil?
    result
  end

  def vpx_settings
    @vpx_settings ||= begin
      data = {}
      resource[:vpx_settings].keys.sort.each do |prop|
        v = cur_vpx_value(prop)[:value]
        case v 
        when FalseClass
          # do nothing, note: v = :false caused setter to run even if they match
        when TrueClass
          # do nothing, note: v = :true      ''          ''          ''
        else
          v = v.to_s
        end
        data[prop] = v
      end
      data
    end
  end

  def vpx_settings=(value)
    resource[:vpx_settings].each do |prop,value|
      value_type = config.supportedOption.find{|x| x[:key] == prop}[:optionType].class
      case value_type.to_s
      when 'IntOption'
        raise Puppet::Error, " value for #{prop}: #{value},  must be an integer" if value !~ /^\d+/
        # TODO, add check for min/max values allowed
        value = RbVmomi::BasicTypes::Int.new value
      when 'BoolOption'
        # might be a shorter way to do the same, also could run this in getter versus here
        case value
        when TrueClass
          # do nothing, all is well
        when FalseClass
          # do nothing, all is well
        else
          raise Puppet::Error, "value must be true/false"
        end
      else
        # do nothing
      end
      
      if vpx_settings[prop] != value
        Puppet.debug("updatng setting: #{prop}")
        config.UpdateOptions({'changedValue' => [ 'key' => prop, 'value' => value]})
      end
    end
  end

end
