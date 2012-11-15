require 'hashdiff'
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
      value
    else
      value
    end
  end

  def camel_name
    PuppetX::VMware::Util.camelize(self.class.name, :lower)
  end
end

class Puppet::Property::VMware_Hash < Puppet::Property::VMware

  def munge(value)
    value = camel_munge(value)
  end

  def is_to_s(v)
    v.inspect
  end

  def should_to_s(v)
    v.inspect
  end

  def insync?(current)
    desire = @should.first
    current ||= {}
    diff = HashDiff.diff(desire, current)
    diff.empty? or diff.select{|x| x.first != '+'}.empty?
  end
end
