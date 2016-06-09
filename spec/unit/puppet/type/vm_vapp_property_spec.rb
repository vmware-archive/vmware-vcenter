require 'spec_helper'

describe Puppet::Type.type(:vm_vapp_property) do
  parameters = [ :name, :vm_name, :datacenter ]
  properties = [
    :category,
    :class_id,
    :default_value,
    :description,
    :id,
    :instance_id,
    :label,
    :type,
    :user_configurable,
    :value
  ]

  parameters.each do |parameter|
    it "should have a #{parameter} parameter" do
      expect(described_class.attrclass(parameter).ancestors).to be_include(Puppet::Parameter)
    end
  end

  properties.each do |property|
    it "should have a #{property} property" do
      expect(described_class.attrclass(property).ancestors).to be_include(Puppet::Property)
    end
  end
end
