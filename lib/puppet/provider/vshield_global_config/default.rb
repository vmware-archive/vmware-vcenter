require 'puppet/provider/vshield'

Puppet::Type.type(:vshield_global_config).provide(:vshield_global_config, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShield global config.'

  Puppet::Type.type(:vshield_global_config).properties.collect{|x| x.name}.each do |prop|
    camel_prop = PuppetX::VMware::Util.camelize(prop, :lower)

    define_method(prop) do
      config[camel_prop]
    end

    define_method("#{prop}=") do |value|
      value = { camel_prop => value }

      case prop
      when :vc_info
        # This specific request appears to be order sensitive with attributes.
        # See https://github.com/savonrb/gyoku/blob/master/README.md#sort-xml-tags
        value[camel_prop][:order!] = ['ipAddress', 'userName', 'password']
      end

      # See https://github.com/savonrb/gyoku/blob/master/README.md#xml-attributes
      data = {
        :vsmGlobalConfig => value,
        :attributes! => {
          :vsmGlobalConfig => { :xmlns => 'vmware.vshield.edge.2.0' }
        }
      }

      post('global/config', data)
    end
  end

  private

  def config
    @config ||= get('global/config')['vsmGlobalConfig']
  end
end
