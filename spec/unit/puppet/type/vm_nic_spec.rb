require 'spec_helper'

describe Puppet::Type.type(:vm_nic) do
  parameters = [ :name, :vm_name, :datacenter, :portgroup_type ]
  properties = [ ]

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

  ## This type is ensurable
  ## some basic provider sanity checking, check that this type has matching provider
  ## and check that all providers of this type support, at the minimum, an
  ## exists?, create and destroy method.
  #
  it "should have one or more providers" do
    expect(described_class.providers).not_to be_empty
  end

  described_class.providers.each do |provider|
    it "the #{provider} provider should support an exists? method" do
      expect(described_class.provider(provider).instance_method(:exists?)).not_to be_nil
    end
    it "the #{provider} provider should support a create method" do
      expect(described_class.provider(provider).instance_method(:create)).not_to be_nil
    end
    it "the #{provider} provider should support a destroy method" do
      expect(described_class.provider(provider).instance_method(:destroy)).not_to be_nil
    end
  end
end
