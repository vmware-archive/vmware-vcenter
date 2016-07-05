require 'spec_helper'

describe Puppet::Type.type(:vm_tools_config) do
  parameters = [ :name, :vm_name, :datacenter ]
  properties = [
    :after_power_on,
    :after_resume,
    :before_guest_reboot,
    :before_guest_shutdown,
    :before_guest_standby,
    :sync_time_with_host,
    :tools_upgrade_policy
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
