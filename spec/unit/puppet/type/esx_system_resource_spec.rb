require 'spec_helper'

describe Puppet::Type.type(:esx_system_resource) do
  parameters = [
    :name,
    :host,
    :system_resource,
    :cpu_unlimited,
    :memory_unlimited
  ]
  properties = [
    :cpu_reservation,
    :cpu_expandable_reservation,
    :cpu_limit,
    :memory_reservation,
    :memory_expandable_reservation,
    :memory_limit
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
