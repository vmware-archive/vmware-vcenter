require 'puppet_x/vmware/util'

class Puppet::Property::VMware < Puppet::Property

  include PuppetX::VMware::Util

  def camel_munge(value, uppercase = false)
    case value
    when Hash
      value.each do |k, v|
        camel_k = PuppetX::VMware::Util.camelize(k, :lower)
        value[camel_k] = camel_munge v
        value.delete k unless k == camel_k
      end
    else
      value
    end
  end

  def camel_name
    PuppetX::VMware::Util.camelize(self.class.name, :lower)
  end
end

class Puppet::Property::VMware::Hash < Puppet::Property::VMware
  def munge(value)
    value = camel_munge(value)
  end
end
