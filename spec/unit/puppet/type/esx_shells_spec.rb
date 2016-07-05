require 'spec_helper'

describe Puppet::Type.type(:esx_shells) do
  parameters = [ :host ]
  properties = [ :suppress_shell_warning, :esxi_shell_time_out, :esxi_shell_interactive_time_out ]

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
