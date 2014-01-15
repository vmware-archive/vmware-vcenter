require 'spec_helper'

describe Puppet::Type.type(:esx_mem) do
  let(:title) { 'esx_mem' }

  context 'should compile with given test params' do
    let(:params) { {
		 :name             			=> '172.16.103.186',
         :configure_mem             => 'true',
         :install_mem       		=> 'true',
         :script_executable_path    => '/usr/bin/perl',
         :setup_script_filepath     => '/opt/Dell/scripts/EquallogicMEM/setup.pl',
         :host_username             => 'root',
         :host_password             => 'iforgot@123',
         :storage_groupip           => '192.168.110.3',
         :iscsi_vmkernal_prefix     => 'iSCSI',
         :vnics_ipaddress           => '192.168.110.10,192.168.110.11',
         :iscsi_vswitch             => 'vSwitch3',
         :iscsi_netmask             => '255.255.255.0',
         :vnics                     => 'vmnic2,vmnic3',
         :iscsi_chapuser            => 'chap_user',
         :iscsi_chapsecret          => 'chap_pwd',
         :disable_hw_iscsi          => 'true'
      }}
    it do
      expect {
        should compile
      }
    end

  end

  it "should have name as one of its parameters" do
    described_class.key_attributes.should == [:name]
  end

    context "when validating values" do

       describe "validating configure_mem property" do

        it "should support configure_mem" do
          described_class.new(:name => '172.16.103.186', :configure_mem => 'true', :script_executable_path => '/usr/bin/perl', :setup_script_filepath => '/opt/Dell/scripts/EquallogicMEM/setup.pl', :host_username  => 'root', :host_password  => 'iforgot@123', :storage_groupip  => '192.168.110.3', :iscsi_vmkernal_prefix  => 'iSCSI', :vnics_ipaddress  => '192.168.110.10,192.168.110.11',:iscsi_vswitch  => 'vSwitch3',:iscsi_netmask  => '255.255.255.0',:vnics  => 'vmnic2,vmnic3',:iscsi_chapuser  => 'chap_user',:iscsi_chapsecret  => 'chap_pwd', :disable_hw_iscsi => 'true')[:configure_mem].should == :true
        end

        it "should support install_mem" do
          described_class.new(:name => '172.16.103.186', :install_mem => 'true', :script_executable_path => '/usr/bin/perl', :setup_script_filepath => '/opt/Dell/scripts/EquallogicMEM/setup.pl', :host_username  => 'root', :host_password  => 'iforgot@123')[:install_mem].should == :true
        end
      end
    end

  end