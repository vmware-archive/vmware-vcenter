require 'spec_helper'

describe Puppet::Type.type(:esx_system_resource) do
  parameters = [
    :name,
    :host,
    :system_resource,
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

  context "cpu resources" do
    it "should set cpu_limit to -1 when unlimited" do
      expect(
        described_class.new(
          :name => 'foo', :cpu_limit => 'unlimited')[:cpu_limit]
      ).to eq(-1)
      expect(
        described_class.new(
          :name => 'foo', :cpu_limit => 400)[:cpu_limit]
      ).to eq(400)
    end
  end
  context "memory resources" do
    it "should set memory_limit to -1 when unlimited" do
      expect(
        described_class.new(
          :name => 'foo', :memory_limit => 'unlimited')[:memory_limit]
      ).to eq(-1)
      expect(
        described_class.new(
          :name => 'foo', :memory_limit => 400)[:memory_limit]
      ).to eq(400)
    end
  end
end
