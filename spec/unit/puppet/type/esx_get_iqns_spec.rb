require 'spec_helper'

describe Puppet::Type.type(:esx_get_iqns) do
  let(:title) { 'esx_get_iqns' }

  context 'should compile with given test params' do
    let(:params) { {
       :host         => '172.16.100.56',
       :hostusername => 'root',
       :hostpassword => 'iforgot@123',
       
      }}
    it do
      expect {
        should compile
      }
    end

  end

  it "should have host as one of its parameters for host name" do
    described_class.key_attributes.should == [:host]
  end
 

  end
