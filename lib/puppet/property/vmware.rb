require 'hashdiff'
require 'pathname' # WORK_AROUND #14073 and #7788
module_lib = Pathname.new(__FILE__).parent.parent.parent
require File.join module_lib, 'puppet_x/vmware/util'

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

class Puppet::Property::VMware_Array < Puppet::Property::VMware

  # Something retarded internally converts false boolean to true, so using symbols.
  def self.sort
    @sort ||= :true
  end

  def self.sort=(value)
    raise Puppet::Error, 'VMWare_Array sort property must be :true or :false.' unless [:true, :false].include? value
    @sort = value
  end

  def self.inclusive
    @inclusive ||= :true
  end

  def self.inclusive=(value)
    raise Puppet::Error, 'VMWare_Array sort property must be :true or :false.' unless [:true, :false].include? value
    @inclusive = (value == true)
  end

  def is_to_s(v)
    v.inspect
  end

  def should_to_s(v)
    v.inspect
  end

  def insync?(is)
    # Handle the case when the current value is nil.
    # If the provider expects array property nil == [], it should return [] in the property getter.
    return @should.nil? if is.nil?

    if self.class.inclusive == :true
      if self.class.sort == :true
        is.sort == @should.sort
      else
        is == @should
      end
    else
      (@should - is).empty?
    end
  end
end
