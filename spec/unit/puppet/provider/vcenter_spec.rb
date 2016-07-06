
require 'spec_helper'
require 'puppet/provider/vcenter'
require 'fixtures/unit/puppet_x/puppetlabs/transport_fixture'

describe Puppet::Provider::Vcenter do

 before do
   @transport = Vcenter::Spec_fixtures::Transport.new.transport
   provider.stubs(:rootfolder).returns('/test')
 end

 let(:provider) { Puppet::Provider::Vcenter.new }
 let(:stubbed_resource) { Puppet::Resource.new('Vcenter[test]') }
 let(:fake_class) { Class.new }
 

 context "when loaded" do
   it "should parse" do
     expect(provider).to be_a(Puppet::Provider::Vcenter)
   end
 end

 describe "#basename" do
   it do
     expect(provider.basename('/foo/bar/baz')).to eq('baz')
   end
 end

 describe "#parent" do
   it do
     expect(provider.parent('/foo/bar/baz')).to eq('/foo/bar')
   end
 end

 describe "#vim" do
   it "should return the transports vim method" do

     expect(PuppetX::Puppetlabs::Transport).to receive(:retrieve).with(
       :resource_ref=>nil,
       :catalog=>nil,
       :provider=>"vsphere").and_return(@transport)

     @transport.stubs(:vim).returns(Vcenter::Spec_fixtures::VimObject)
     provider.stubs(:resource).returns(stubbed_resource)
     expect(provider.vim).to eq(@transport.vim)
   end
 end


 describe "#vmfolder" do
   context "when an invalid path is given" do
     it "should raise an error" do
       provider.expects(:locate).with('/bar').returns(nil)
       expect { provider.vmfolder('/bar') }.to raise_error(Puppet::Error, /Invalid path: \/bar/)
     end
   end

   context "when given /" do
     it "should return the rootfolder" do
       provider.expects(:return_folder).with('/test').returns(Vcenter::Spec_fixtures::FolderObject)
       expect(provider.vmfolder('/')).to eq(Vcenter::Spec_fixtures::FolderObject)
     end
   end

   context "when given a path" do
     it "should invoke the locate method" do
       provider.expects(:locate).with('/bar').returns(Vcenter::Spec_fixtures::FolderObject)
       provider.expects(:return_folder).with(Vcenter::Spec_fixtures::FolderObject).returns(Vcenter::Spec_fixtures::FolderObject)
       expect(provider.vmfolder('/bar')).to eq(Vcenter::Spec_fixtures::FolderObject)
     end
   end
 end

 ################################
 # return_folder
 #
 # Test the return_folder method.
 # ensure that depending on which type of object is given as an argument
 # that the right actions are taken.
 describe "#return_folder" do

   before(:each) do
     stub_const("RbVmomi::VIM::Folder", Class.new)
     stub_const("RbVmomi::VIM::ComputeResource", Class.new)
     stub_const("RbVmomi::VIM::Datacenter", Class.new)
     stub_const("RbVmomi::VIM::ClusterComputeResource", Class.new)
     stub_const("Unknown::Class", Class.new)
   end
  
   context "When given a RbVmomi::VIM::Folder" do
     it "should return the given object" do
       folder = RbVmomi::VIM::Folder.new
       expect(provider.return_folder(folder)).to eq(folder)
     end
   end

   context "Whe given a RbVmomi::VIM::ComputeResource" do
     it "should return the resourcePool method" do
       computeresource = RbVmomi::VIM::ComputeResource.new
       resource_pool = Class.new
       expect(computeresource).to receive(:resourcePool).with(no_args).and_return(resource_pool)
       expect(provider.return_folder(computeresource)).to eq(resource_pool)
     end
   end


   context "Whe given a RbVmomi::VIM::Datacenter" do
     it "should return the hostFolder method" do
       datacenter = RbVmomi::VIM::Datacenter.new
       host_folder = Class.new
       expect(datacenter).to receive(:hostFolder).with(no_args).and_return(host_folder)
       expect(provider.return_folder(datacenter)).to eq(host_folder)
     end
   end

   context "When given a RbVmomi::VIM::ClusterComputeResource" do
     it "should return the given object" do
       clustercomputeresource = RbVmomi::VIM::ClusterComputeResource.new
       expect(provider.return_folder(clustercomputeresource)).to eq(clustercomputeresource)
     end
   end

   context "When given a nil argument" do
     it "should throw an invalid path error" do
       provider.instance_variable_set("@resource", {})
       expect { provider.return_folder(nil) }.to raise_error(Puppet::Error, /Invalid path/)
     end
   end

   context "When given an unknown class type" do
     it "should throw an unknown container error" do
       expect { 
         provider.return_folder(Unknown::Class.new)
       }.to raise_error(Puppet::Error, /Unknown container type/)
     end
   end

 end

end
