require 'spec_helper'

describe Puppet::Type.type(:esx_firewall_ruleset) do

  context 'when invoked' do
    let(:title) { 'ntpClient' }
    let(:params) {{
      :path => '/data/center/',
      :host => '192.168.2.2',
    }}
    it "should compile" do
      expect { compile }
    end
  end

  context 'namevar' do
    it "should have name and host as its keyattribute" do
      expect(described_class.key_attributes).to include( :name, :host )
    end
  end
  context 'when declared using title as namevar' do
    let(:resource) {
      described_class.new(
        :title => 'ntpClient',
        :path  => '/data/center',
        :host  => '192.168.22.1'
      )
    }

    it "should set the name to the title" do
      expect(resource.name).to eq('ntpClient')
    end
  end

  context 'when declared with the name parameter' do
    let (:resource) {
      described_class.new(
        :title => 'discard',
        :name  => 'ntpClient',
        :path  => '/data/center',
        :host  => '192.168.22.1'
      )
    }

    it "should set the name to the title" do
      expect(resource.name).to eq('ntpClient')
    end
  end

  context "the path attribute" do
    let (:params) {{
        :title => 'discard',
        :name  => 'ntpClient',
        :host  => '192.168.22.1'
    }}
    it "should raise an error if path is missing" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
    it "should raise an error if the path is not absolute" do
      params[:path] = 'foo'
      expect { described_class.new }.to raise_error(ArgumentError)
    end
  end

  context 'when declared with comma delimited title' do
    let (:resource) {
      described_class.new(
        :title => '192.168.22.1:ntpClient',
        :path  => '/data/center',
      )
    }

    it "should set the host and name from the namevar" do
      expect(resource.name).to eq('ntpClient')
      expect(resource[:host]).to eq('192.168.22.1')
    end
  end

  context "the ensure attribute" do
    let (:params) {{
      :title => '192.168.22.1:ntpClient',
      :path  => '/data/center',
    }}

    it "should allow values of enabled,disabled,present or absent" do
      [ 'enabled', 'disabled', 'present', 'absent' ].each do |p|
        expect { described_class.new(params.merge({:ensure => p})) }.not_to raise_error
      end
    end

    it "should raise error on any other value" do
      params[:ensure] = 'bad_state'
      expect {  described_class.new(params) }.to raise_error(Puppet::Error)
    end

    it "should map present to enabled" do
      params[:ensure] = 'present'
      expect(described_class.new(params)[:ensure]).to eq(:enabled)
    end

    it "should map absent to disabled" do
      params[:ensure] = 'absent'
      expect(described_class.new(params)[:ensure]).to eq(:disabled)
    end
  end
      

  context "when validating allowed_hosts" do
     let(:params) {{
        :title => '192.168.22.1:ntpClient',
        :path  => '/data/center',
     }}

     it "should allow the string 'all'" do
       params['allowed_hosts'] = 'all'
       expect { described_class.new(params) }.not_to raise_error
     end

     it "should allow an array" do
       params['allowed_hosts'] = [ '192.168.21.1', '192.168.21.2', '192.168.99.0/24' ]
       expect { described_class.new(params) }.not_to raise_error
     end
     
     it "should not allow any other string" do
       params['allowed_hosts'] = 'bad'
       expect { described_class.new(params) }.to raise_error(Puppet::Error)
     end

     it "should not allow a malformed ip address in the array" do
       params['allowed_hosts'] = [ '192.168.21.1', '192.168.21.2/BAD', '192.168.99.0/24' ]
       expect { described_class.new(params) }.to raise_error(Puppet::Error)
     end
  end

  context "when evaluating allowedhosts" do
     let(:params) {{
        :ensure => :enabled,
        :title => '192.168.22.1:ntpClient',
        :path  => '/data/center',
        :allowed_hosts => [ '192.168.21.1', '192.168.21.2', '192.168.99.0/24' ],
     }}
     let(:resource) { described_class.new(params) }

     it "should not care about the order" do
       is =  [ '192.168.99.0/24', '192.168.21.1', '192.168.21.2']
       expect(resource.property(:allowed_hosts).insync?(is)).to eq(true)
     end

     it "should recognise removed values as out of sync" do
       is =  [ '192.168.21.2', '192.168.99.0/24' ]
       expect(resource.property(:allowed_hosts).insync?(is)).to eq(false)
     end

     it "should recognise new values as out of sync" do
       is = [ '192.168.21.1', '192.168.21.2', '192.168.99.0/24', '10.0.0.1' ]
       expect(resource.property(:allowed_hosts).insync?(is)).to eq(false)
     end

  end
end
