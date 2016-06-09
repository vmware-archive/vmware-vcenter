require 'spec_helper'

describe Puppet::Type.type(:esx_syslog) do
  parameters = [ :host ]
  properties = [ :log_dir, :log_host, :log_dir_unique, :default_rotate, :default_size ]

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
