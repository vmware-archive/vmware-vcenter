require 'spec_helper'

describe Puppet::Type.type(:esx_datastore) do
  parameters = [ :name, :datastore, :host, :local_path, :access_mode, :user_name, :password, :lun, :uid ]
  properties = [ :type, :remote_host, :remote_path ]

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
