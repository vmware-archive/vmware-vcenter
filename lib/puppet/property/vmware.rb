require 'puppet_x/vmware/util'

class Puppet::Property::VMware < Puppet::Property

  include PuppetX::VMware::Util

  def camel_munge(value, uppercase = false)
    case value
    when Hash
      value.each do |k, v|
        value[PuppetX::VMware::Util.camelize(k, :lower)] = camel_munge v
        value.delete k
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
