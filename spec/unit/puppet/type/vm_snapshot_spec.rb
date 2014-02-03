require 'spec_helper'

describe Puppet::Type.type(:vm_snapshot) do

  let(:title) { 'vm_snapshot' }

  context 'should compile with given test params' do
    let(:params) { {
        :name   => 'testsnapshot',
        :memory_snapshot => true,
        :snapshot_supress_power_on => true,
        :vm_name   => 'testvm',
        :snapshot_operation   => 'create',
        :datacenter   => 'datacenter1',
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
      [:name, :memory_snapshot, :snapshot_supress_power_on, :vm_name, :datacenter].each do |param|
        it "should be a #{param} parameter" do
          described_class.attrtype(param).should == :param
        end
      end

      [:snapshot_operation].each do |property|
        it "should be a #{property} property" do
          described_class.attrtype(property).should == :property
        end
      end
    end

    describe "when validating values" do

      describe "validating name param" do
        it "should be valid name value" do
          described_class.new(:name => 'testsnapshot',:memory_snapshot => true, :snapshot_supress_power_on => true, :vm_name => 'testvm', :snapshot_operation => 'create', :datacenter => 'datacenter1')[:name].should == 'testsnapshot'
        end

        it "should not be a blank name value" do
          expect { described_class.new(:name => '',:memory_snapshot => true, :snapshot_supress_power_on => true, :vm_name => 'testvm', :snapshot_operation => 'create', :datacenter => 'datacenter1') }.to raise_error Puppet::Error
        end
      end

      describe "validating memory_snapshot param" do
        it "should be a valid memory_snapshot value" do
          described_class.new(:name => 'testsnapshot',:memory_snapshot => true, :snapshot_supress_power_on => true, :vm_name => 'testvm', :snapshot_operation => 'create', :datacenter => 'datacenter1')[:memory_snapshot].should.to_s == true
        end

        it "should not allow invalid memory_snapshot value" do
          expect {described_class.new(:name => 'testsnapshot',:memory_snapshot => 'foo', :snapshot_supress_power_on => true, :vm_name => 'testvm', :snapshot_operation => 'create', :datacenter => 'datacenter1')}.to raise_error Puppet::Error
        end
      end

      describe "validating snapshot_supress_power_on param" do
        it "should be a valid snapshot_supress_power_on value" do
          described_class.new(:name => 'testsnapshot',:memory_snapshot => true, :snapshot_supress_power_on => true, :vm_name => 'testvm', :snapshot_operation => 'create', :datacenter => 'datacenter1')[:snapshot_supress_power_on].should.to_s == true
        end

        it "should not allow invalid snapshot_supress_power_on value" do
          expect {described_class.new(:name => 'testsnapshot',:memory_snapshot => true, :snapshot_supress_power_on => 'foo', :vm_name => 'testvm', :snapshot_operation => 'create', :datacenter => 'datacenter1')}.to raise_error Puppet::Error
        end
      end

      describe "validating vm_name param" do
        it "should be valid vm_name value" do
          described_class.new(:name => 'testsnapshot',:memory_snapshot => true, :snapshot_supress_power_on => true, :vm_name => 'testvm', :snapshot_operation => 'create', :datacenter => 'datacenter1')[:vm_name].should == 'testvm'
        end

        it "should not be a blank vm_name value" do
          expect { described_class.new(:name => 'testsnapshot',:memory_snapshot => true, :snapshot_supress_power_on => true, :vm_name => '', :snapshot_operation => 'create', :datacenter => 'datacenter1') }.to raise_error Puppet::Error
        end
      end

      describe "validating datacenter param" do
        it "should be valid datacenter value" do
          described_class.new(:name => 'testsnapshot',:memory_snapshot => true, :snapshot_supress_power_on => true, :vm_name => 'testvm', :snapshot_operation => 'create', :datacenter => 'datacenter1')[:datacenter].should == 'datacenter1'
        end

        it "should not be a blank vm_name value" do
          expect { described_class.new(:name => 'testsnapshot',:memory_snapshot => true, :snapshot_supress_power_on => true, :vm_name => 'testvm', :snapshot_operation => 'create', :datacenter => '') }.to raise_error Puppet::Error
        end
      end

      describe "validating snapshot_operation property" do
        it "should be a valid snapshot_operation value" do
          described_class.new(:name => 'testsnapshot',:memory_snapshot => true, :snapshot_supress_power_on => true, :vm_name => 'testvm', :snapshot_operation => 'create', :datacenter => 'datacenter1')[:snapshot_operation].should.to_s == 'create'
        end

        it "should be a valid snapshot_operation value" do
          described_class.new(:name => 'testsnapshot',:memory_snapshot => true, :snapshot_supress_power_on => true, :vm_name => 'testvm', :snapshot_operation => 'remove', :datacenter => 'datacenter1')[:snapshot_operation].should.to_s == 'remove'
        end

        it "should be a valid snapshot_operation value" do
          described_class.new(:name => 'testsnapshot',:memory_snapshot => true, :snapshot_supress_power_on => true, :vm_name => 'testvm', :snapshot_operation => 'revert', :datacenter => 'datacenter1')[:snapshot_operation].should.to_s == 'revert'
        end

        it "should not allow invalid snapshot_operation value" do
          expect {described_class.new(:name => 'testsnapshot',:memory_snapshot => 'foo', :snapshot_supress_power_on => true, :vm_name => 'testvm', :snapshot_operation => 'foo', :datacenter => 'datacenter1')}.to raise_error Puppet::Error
        end
      end

    end
  end
end
