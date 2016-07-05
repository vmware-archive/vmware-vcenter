require 'spec_helper'

describe Puppet::Type.type(:vc_cluster_drs) do
  parameters = [ :path ]
  properties = [ :enabled, :enable_vm_behavior_overrides, :default_vm_behavior, :vmotion_rate ]

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
