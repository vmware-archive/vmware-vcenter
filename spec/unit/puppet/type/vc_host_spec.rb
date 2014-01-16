require 'spec_helper'

describe Puppet::Type.type(:vc_host) do

  let(:title) { 'vc_host' }

  context 'should compile with given test params' do
    let(:params) { {
        :name      => 'esx1',
        :ensure    => 'present',
        :path      => '/datacenter1',
        :username  => 'foo',
        :password  => 'password',
        :sslthumbprint => 'foobar',
        :secure => 'false'
      }}
    it do
      expect {
        should compile
      }
    end

  end

  context "when validating attributes" do

    it "should have name as its keyattribute" do
      described_class.key_attributes.should == [:name]
    end

    describe "when validating attributes" do
      [:name, :username, :password, :sslthumbprint, :secure].each do |param|
        it "should be a #{param} parameter" do
          described_class.attrtype(param).should == :param
        end
      end

      [:ensure, :path].each do |property|
        it "should be a #{property} property" do
          described_class.attrtype(property).should == :property
        end
      end
    end

    describe "when validating values" do

      describe "validating name param" do
        it "should allow a valid name" do
          described_class.new(:name => 'esx1', :ensure => 'present', :path => '/datacenter1', :username => 'foo', :password => 'password',
          :sslthumbprint => 'foobar', :secure => 'false')[:name].should == 'esx1'
        end

        it "should not allow blank value in the name" do
          expect { described_class.new(:name => '', :ensure => 'present', :path => '/datacenter1', :username => 'foo', :password => 'password',
            :sslthumbprint => 'foobar', :secure => 'false') }.to raise_error Puppet::Error
        end
      end

      describe "validating username param" do
        it "should allow a valid username" do
          described_class.new(:name => 'esx1', :ensure => 'present', :path => '/datacenter1', :username => 'foo', :password => 'password',
          :sslthumbprint => 'foobar', :secure => 'false')[:username].should == 'foo'
        end

        it "should not allow blank value in the username" do
          expect { described_class.new(:name => 'esx1', :ensure => 'present', :path => '/datacenter1', :username => '', :password => 'password',
            :sslthumbprint => 'foobar', :secure => 'false') }.to raise_error Puppet::Error
        end
      end

      describe "validating password param" do

        it "should allow a valid password" do
          described_class.new(:name => 'esx1', :ensure => 'present', :path => '/datacenter1', :username => 'foo', :password => 'password',
          :sslthumbprint => 'foobar', :secure => 'false')[:password].should == 'password'
        end

        it "should not allow blank value in the password" do
          expect { described_class.new(:name => 'esx1', :ensure => 'present', :path => '/datacenter1', :username => 'foo', :password => '',
            :sslthumbprint => 'foobar', :secure => 'false') }.to raise_error Puppet::Error
        end
      end

      describe "validating sslthumbprint param" do

        it "should allow a valid sslthumbprint" do
          described_class.new(:name => 'esx1', :ensure => 'present', :path => '/datacenter1', :username => 'foo', :password => 'password',
          :sslthumbprint => 'foobar', :secure => 'false')[:sslthumbprint].should == 'foobar'
        end
      end

      describe "validating path property" do

        it "should allow a valid path" do
          described_class.new(:name => 'esx1', :ensure => 'present', :path => '/datacenter1', :username => 'foo', :password => 'password',
          :sslthumbprint => 'foobar', :secure => 'false')[:path].should == '/datacenter1'
        end

        it "should not invalid path values" do
          expect { described_class.new(:name => 'esx1', :ensure => 'present', :path => '####datacenter1', :username => 'foo', :password => 'password',
            :sslthumbprint => 'foobar', :secure => 'false') }.to raise_error Puppet::Error
        end
      end

      describe "validating ensure property" do

        it "should support present value" do
          described_class.new(:name => 'esx1', :ensure => 'present', :path => '/datacenter1', :username => 'foo', :password => 'password',
          :sslthumbprint => 'foobar', :secure => 'false')[:ensure].should == :present
        end

        it "should support absent value" do
          described_class.new(:name => 'esx1', :ensure => 'absent', :path => '/datacenter1', :username => 'foo', :password => 'password',
          :sslthumbprint => 'foobar', :secure => 'false')[:ensure].should == :absent
        end

        it "should not allow values other than present or absent" do
          expect { described_class.new(:name => 'esx1', :ensure => 'foo', :path => '/datacenter1', :username => 'foo', :password => 'password',
            :sslthumbprint => 'foobar', :secure => 'false') }.to raise_error Puppet::Error
        end

      end

      describe "validating secure param" do

        it "should support true value" do
          described_class.new(:name => 'esx1', :ensure => 'present', :path => '/datacenter1', :username => 'foo', :password => 'password',
          :sslthumbprint => 'foobar', :secure => 'true')[:secure].should.to_s == 'true'
        end

        it "should support false value" do
          described_class.new(:name => 'esx1', :ensure => 'absent', :path => '/datacenter1', :username => 'foo', :password => 'password',
          :sslthumbprint => 'foobar', :secure => 'false')[:secure].should.to_s == 'false'
        end

        it "should not allow values other than true or false" do
          expect { described_class.new(:name => 'esx1', :ensure => 'foo', :path => '/datacenter1', :username => 'foo', :password => 'password',
            :sslthumbprint => 'foobar', :secure => 'foo') }.to raise_error Puppet::Error
        end

      end

    end
  end
end
