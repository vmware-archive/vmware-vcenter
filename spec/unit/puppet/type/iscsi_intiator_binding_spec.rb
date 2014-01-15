require 'spec_helper'

describe Puppet::Type.type(:iscsi_intiator_binding) do
  let(:title) { 'iscsi_intiator_binding' }

  context 'should compile with given test params' do
    let(:params) { {
		  :name                   =>  '172.28.8.102: vmhba33',
      :vmknics                => 'vmk1',
      :script_executable_path => '/usr/bin/esxcli',
      :host_username          => 'root',
      :host_password          => 'P@ssw0rd',
      :ensure                 => 'present', 
      }}
    it do
      expect {
        should compile
      }
    end

  end

  it "should have name as one of its parameters for host and vmhba name" do
    described_class.key_attributes.should == [:name]
  end

    context "when validating values" do

       describe "validating ensure property" do

        it "should support present" do
          described_class.new(:name => '172.28.8.102: vmhba33',:vmknics => 'vmk1', :script_executable_path => '/usr/bin/esxcli', :host_username => 'root', :host_password => 'P@ssw0rd', :ensure  => 'present')[:ensure].should == :present
        end

        it "should support absent" do
          described_class.new(:name => '172.28.8.102: vmhba33',:vmknics => 'vmk1', :script_executable_path => '/usr/bin/esxcli', :host_username => 'root', :host_password => 'P@ssw0rd',  :ensure  => 'absent')[:ensure].should == :absent
        end

        it "should not support other values" do
          expect { described_class.new(:name => '172.28.8.102: vmhba33',:vmknics => 'vmk1', :script_executable_path => '/usr/bin/esxcli', :host_username => 'root', :host_password => 'P@ssw0rd', :ensure  => 'negativetest') }.to raise_error(Puppet::Error, /Invalid value "negativetest"/)
        end
      end
    end

  end


