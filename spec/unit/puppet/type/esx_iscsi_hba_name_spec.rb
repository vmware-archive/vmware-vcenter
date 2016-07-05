require 'spec_helper'

describe Puppet::Type.type(:esx_iscsi_hba_name) do
  parameters = [ :host_hba, :esx_host, :hba_name ]
  properties = [ :iscsi_name ]

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
