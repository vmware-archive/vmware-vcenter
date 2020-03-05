require "spec_helper"
require "yaml"
require "puppet/provider/vcenter"
require "rspec/mocks"
require "fixtures/unit/puppet/provider/vc_vm/vc_vm_fixture"
require "hashie"

provider_path = Pathname.new(__FILE__).parent.parent.parent.parent.parent.parent

describe "vm create and clone behavior testing" do
  let(:fixture) {Vc_vm_fixture.new}
  let(:provider) {fixture.provider}
  let(:datacenter) {mock("datacenter")}
  let(:datastore) {mock(:name => "FlexDatastore")}
  let(:vmFolder) {mock(:name => "vm")}
  let(:computeResource) {mock("compute_resource")}
  let(:ovfManager) {mock("ovf_manager")}
  let(:vm) {mock("vm")}
  let(:pci_dev) {mock("pci_device")}
  let(:hardware) {mock("hardware")}
  let(:device) {mock("device")}
  let(:config) {mock("config")}
  let(:task) {mock("task")}
  let(:serviceContent) {mock(:ovfManager => ovfManager)}
  #let(:host) {mock(:name => "newFlexVM")}
  let(:host) {mock("newFlex")}
  let(:serviceInstance) {mock(:find_datacenter => datacenter)}
  let(:vim) {mock(:serviceInstance => serviceInstance)}
  let(:net1) {mock("network1")}
  let(:net2) {mock("network2")}
  let(:net3) {mock("network3")}
  
  context "when vc_vm provider is created " do
    it "should have a create method defined for vc_vm" do
      expect(provider.class.instance_method(:create)).to be_truthy
    end

    it "should have a destroy method defined for vc_vm" do
      expect(provider.class.instance_method(:destroy)).to be_truthy
    end

    it "should have a exists? method defined for vc_vm" do
      expect(provider.class.instance_method(:exists?)).to be_truthy
    end

    it "should have a parent 'Puppet::Provider::Vcentre'" do
      expect(provider).to be_kind_of(Puppet::Provider::Vcenter)
    end
  end

  context "when vc_vm will create nvdimm configuration" do
    it "should return host datastores" do
      host = mock("host")
      datastore1 = mock("datastore1")
      datastore2 = mock("datastore2")
      summary1 = mock("summary1")
      summary2 = mock("summary2")
      summary1.expects(:type).returns("Other")
      summary2.expects(:type).returns("PMEM")
      datastore1.expects(:summary).returns(summary1)
      datastore2.expects(:summary).returns(summary2)
      datastores = [datastore1, datastore2]
      host.expects(:datastore).returns(datastores)
      provider.expects(:find_vm_host).returns(host)
      expect(provider.host_nvdimm_datastores).to eq([datastore2])
    end

    it "should return host nvdimm datastore names" do
      host = mock("host")
      datastore1 = mock("datastore1")
      datastore2 = mock("datastore2")
      info1 = mock("info1")
      info2 = mock("info2")
      info1.expects(:name).returns("Other")
      info2.expects(:name).returns("PMemDS-14ed2a15-2e15-7f4a-bbfd-c0b1058a03d2")
      datastore1.expects(:info).returns(info1)
      datastore2.expects(:info).returns(info2)
      datastores = [datastore1, datastore2]
      provider.expects(:host_nvdimm_datastores).returns(datastores)
      expect(provider.host_nvdimm_datastore_names).to eq(["Other", "PMemDS-14ed2a15-2e15-7f4a-bbfd-c0b1058a03d2"])
    end

    it "should return vm datastores" do
      this_vm = mock("vm")
      datastore1 = mock("datastore1")
      datastore2 = mock("datastore2")
      datastores = [datastore1, datastore2]
      this_vm.expects(:datastore).returns(datastores)
      provider.expects(:vm).returns(this_vm)
      expect(provider.vm_datastores).to eq(datastores)
    end

    it "should return vm nvdimm datastore" do
      datastore1 = mock("datastore1")
      datastore2 = mock("datastore2")
      summary1 = mock("summary1")
      summary2 = mock("summary2")
      summary1.expects(:name).returns("Other")
      summary2.expects(:name).returns("PMemDS-14ed2a15-2e15-7f4a-bbfd-c0b1058a03d2")
      datastore1.expects(:summary).returns(summary1)
      datastore2.expects(:summary).returns(summary2)
      datastores = [datastore1, datastore2]
      provider.expects(:host_nvdimm_datastore_names).returns(["PMemDS-14ed2a15-2e15-7f4a-bbfd-c0b1058a03d2"]).at_least_once
      provider.expects(:vm_datastores).returns(datastores)
      expect(provider.vm_nvdimm_datastore).to eq(datastore2)
    end

    it "should return nvdimm device spec" do
      datastore1 = mock("datastore1")
      host = mock("host")
      summary = mock("summary")
      quick_stat = mock("quick_stat")
      provider.expects(:host_nvdimm_datastores).returns(datastore1)
      quick_stat.expects(:availablePMemCapacity).returns(48000)
      summary.expects(:quickStats).returns(quick_stat)
      host.expects(:summary).returns(summary)
      provider.expects(:find_vm_host).returns(host)
      RbVmomi::VIM.expects(:VirtualNVDIMM)
      RbVmomi::VIM.expects(:VirtualNVDIMMBackingInfo)
      RbVmomi::VIM.expects(:VirtualMachineDefinedProfileSpec)
      RbVmomi::VIM.expects(:Description)
      RbVmomi::VIM.expects(:VirtualDeviceConfigSpec)
      RbVmomi::VIM.expects(:VirtualDeviceConfigSpecOperation)
      RbVmomi::VIM.expects(:VirtualDeviceConfigSpecFileOperation)
      provider.nvdimm_device_spec
    end

    it "should raise error if insufficient nvdimm host capacity" do
      datastore1 = mock("datastore1")
      host = mock("host")
      summary = mock("summary")
      quick_stat = mock("quick_stat")
      provider.expects(:host_nvdimm_datastores).returns(datastore1)
      quick_stat.expects(:availablePMemCapacity).returns(0)
      summary.expects(:quickStats).returns(quick_stat)
      host.expects(:summary).returns(summary)
      provider.expects(:find_vm_host).returns(host)
      RbVmomi::VIM.expects(:VirtualNVDIMM).never
      RbVmomi::VIM.expects(:VirtualNVDIMMBackingInfo).never
      RbVmomi::VIM.expects(:VirtualMachineDefinedProfileSpec).never
      RbVmomi::VIM.expects(:Description).never
      RbVmomi::VIM.expects(:VirtualDeviceConfigSpec).never
      RbVmomi::VIM.expects(:VirtualDeviceConfigSpecOperation).never
      RbVmomi::VIM.expects(:VirtualDeviceConfigSpecFileOperation).never
      expect {provider.nvdimm_device_spec}
          .to raise_error(RuntimeError, "The capacity 0 is too small to attach NVDIMM.")
    end

    it "should return nvdimm controller spec" do
      RbVmomi::VIM.expects(:VirtualNVDIMMController)
      RbVmomi::VIM.expects(:Description)
      RbVmomi::VIM.expects(:VirtualDeviceConfigSpec)
      RbVmomi::VIM.expects(:VirtualDeviceConfigSpecOperation)
      provider.nvdimm_controller_spec
    end

    it "should configure nvdimm on VM" do
      provider.resource[:disable_nvdimm_alarm] = true
      datastore2 = mock("datastore2")
      datastore = [datastore2]
      provider.expects(:vm_nvdimm_datastore).returns(nil)
      provider.expects(:host_nvdimm_datastores).returns(datastore)
      RbVmomi::VIM.expects(:VirtualMachineConfigSpec)
      provider.expects(:nvdimm_device_spec)
      provider.expects(:nvdimm_controller_spec)
      provider.expects(:power_state).returns("poweredOff").at_least_once
      nvdimm_vm = mock("vm")
      task = mock("task")
      task.expects(:wait_for_completion)
      task.expects(:info).returns(:state => "success")
      nvdimm_vm.expects(:ReconfigVM_Task).returns(task)
      provider.expects(:vm).returns(nvdimm_vm)
      provider.expects(:disable_nvdimm_ds_alarm)
      provider.configure_nvdimm
    end

    it "should disable datastore alarm on nvdimm datastore" do
      datastore = mock("datastore")
      alarm1 = mock("alarm")
      alarm2 = mock("alarm2")
      alarm1.expects(:alarm).returns(alarm2).at_least_once
      info = mock("info")
      info.expects(:name).returns("Datastore usage on disk").at_least_once
      info.expects(:description).returns("Default alarm for datastore usage")
      info.expects(:expression).returns("Alarm expression")
      alarm2.expects(:ReconfigureAlarm).returns(nil)
      alarm2.expects(:info).returns(info).at_least_once
      datastore.expects(:triggeredAlarmState).returns([alarm1])
      provider.expects(:vm_nvdimm_datastore).returns(datastore)
      provider.disable_nvdimm_ds_alarm
    end
  end

  context "when vc_vm is created " do
    before(:each) do
      provider.expects(:vm).at_least_once.returns(nil).returns(mock("vm_object"))
      provider.expects(:cdrom_iso).returns(mock("cdrom_object"))
      provider.expects(:iso_file).returns(mock("cdrom_object"))
      provider.expects(:configure_pci_passthru)
      provider.initialize_property_flush
    end

    it "should create vm  if value of operation is create" do
      provider.expects(:create_vm)

      provider.create
    end

    it "should clone vm  if value of operation is clone" do
      provider.resource[:template] = "mock_template"
      provider.expects(:clone_vm)

      provider.create
    end

    it "should clone vm when nvdimm is enabled" do
      provider.resource[:template] = "mock_template"
      provider.resource[:enable_nvdimm] = true
      provider.expects(:configure_nvdimm)
      provider.expects(:clone_vm)

      provider.create
    end

    it "should deploy ovf if value of operation is deploy as ovf_url provided" do
      provider.resource[:ovf_url] = "http://test/test.ovf"
      provider.resource[:power_state] = "poweredOn"
      datacenter.expects(:find_datastore).returns(datastore)
      datacenter.expects(:find_compute_resource).returns(computeResource)
      datacenter.expects(:vmFolder).returns(vmFolder)
      datacenter.expects(:name).returns("FlexDC")
      provider.expects(:vm_guest_os).never
      vim.expects(:serviceContent).returns(serviceContent)
      task.stubs(:wait_for_completion)
      task.stubs(:info).returns({:state => "success"})
      vm.expects(:ReconfigVM_Task).returns(task)
      hardware.expects(:device).returns([])
      config.expects(:hardware).returns(hardware)
      vm.expects(:config).returns(config)
      ovfManager.expects(:deployOVF).returns(vm)
      computeResource.expects(:resourcePool).returns("rp")
      computeResource.expects(:name).returns("FlexCluster")
      host.expects(:name).returns("FlexHost")
      provider.expects(:host_from_datastore).returns(host)
      provider.expects(:network_mappings).returns({})
      provider.expects(:vim).twice.returns(vim)
      provider.create      
    end
  end

  context "Configuring CPU and memory" do
    it "should raise error if vm reconfiguration fails" do
      provider.expects(:vm).at_least_once.returns(nil).returns(mock("vm_object"))
      provider.resource[:ovf_url] = "http://test/test.ovf"
      provider.resource[:power_state] = "poweredOn"
      datacenter.expects(:find_datastore).returns(datastore)
      datacenter.expects(:find_compute_resource).returns(computeResource)
      datacenter.expects(:vmFolder).returns(vmFolder)
      datacenter.expects(:name).returns("FlexDC")
      vim.expects(:serviceContent).returns(serviceContent)
      task.stubs(:wait_for_completion)
      task.stubs(:info).returns({:state => "error", :error => {:localizedMessage => "Failed to reconfig VM"}})
      vm.stubs(:name).returns("FlexVM")
      vm.expects(:ReconfigVM_Task).returns(task)
      hardware.expects(:device).returns([])
      config.expects(:hardware).returns(hardware)
      vm.expects(:config).returns(config)
      ovfManager.expects(:deployOVF).returns(vm)
      computeResource.expects(:resourcePool).returns("rp")
      computeResource.expects(:name).returns("FlexCluster")
      host.expects(:name).returns("FlexHost")
      provider.expects(:host_from_datastore).returns(host)
      provider.expects(:network_mappings).returns({})
      provider.expects(:vim).twice.returns(vim)
      expect { provider.create }.to raise_error(RuntimeError)
    end
  end

  context "#network mappings" do
    it "should provide network mappings when ovf has networks" do
      ovf_url = File.join(provider_path, '/spec/fixtures/unit/puppet/provider/vc_vm/ovf.xml')
      net1.stubs(:name).returns("FlexMgmt")
      net2.stubs(:name).returns("FlexData1")
      provider.resource[:network_interfaces] = [{"portgroup" => {:pg_name => "FlexMgmt", :vds_name => "VDS1"}}, {"portgroup" => {:pg_name => "FlexData1", :vds_name => "VDS2"}}]
      computeResource.stubs(:network).returns([net1, net2])
      expect(provider.network_mappings(ovf_url,computeResource)).to eq({"VM Network" => net2, "VM Network 1" => net2, "VM Network 2" => net1})
    end  
  end

  context "#adjust_networks_flex_svm" do
    it "should reorder networks" do
      ovf_url = File.join(provider_path, '/spec/fixtures/unit/puppet/provider/vc_vm/ovf.xml')
      network_mappings = {}
      # Query OVF to find any networks which need to be mapped
      begin
        ovf = open(ovf_url, 'r'){|io| Nokogiri::XML(io.read)}
      rescue
        Puppet.debug("Failed to open ovf: %s for reason: %s" % [ovf_url.to_s, $!.to_s])
        raise
      end
      net1.stubs(:name).returns("FlexMgmt")
      net2.stubs(:name).returns("FlexData1")
      net3.stubs(:name).returns("FlexData2")
      ovf.remove_namespaces!
      networks = ovf.xpath('//NetworkSection/Network').map{|x| x['name']}
      net_maps = {"VM Network" => net1, "VM Network 1" => net2, "VM Network 2" => net3}
      new_map = provider.adjust_networks_flex_svm(net_maps, networks)
      expect(new_map).to eq({"VM Network" => net2, "VM Network 1" => net3, "VM Network 2" => net1})
    end
  end

  context "#pci_passthru_device" do
    it "returns passthrough device" do
      provider.stubs(:find_vm_host).returns(host)
      host.expects(:config).returns(config)
      host.stubs(:vm).returns([vm])
      pci_dev.stubs(:passthruActive).returns(true)
      hardware.expects(:device).returns(["RbVmomi::VIM::VirtualPCIPassthrough"])
      config.expects(:pciPassthruInfo).returns([pci_dev])
      config.expects(:hardware).returns(hardware)
      vm.expects(:config).returns(config)
      expect(provider.available_pci_passthru_device).to eq(pci_dev)
    end
 
    it "should configure passthrough device" do
      provider.expects(:available_pci_passthru_device).returns(pci_dev)	
      provider.expects(:pci_passthru_device_spec).returns({})
      task.stubs(:wait_for_completion)
      task.stubs(:info).returns({:state => "success"})
      vm.expects(:ReconfigVM_Task).returns(task)
      provider.expects(:vm).returns(vm)
      provider.configure_pci_passthru
    end	    
  end

  context "when vc_vm calls destroy " do
    let(:destroy_task) {mock("destroy_task")}

    before(:each) do
      provider.stubs(:power_state).returns("poweredOff")
      provider.stubs(:cdrom_iso)
      provider.stubs(:nfs_vm_datastore)
    end

    it "should delete vm " do
      provider.stubs(:vm).returns(mock(:Destroy_Task => destroy_task))

      destroy_task.expects(:wait_for_completion)

      provider.destroy
    end

    it "should receive error if vm not exist" do
      provider.stubs(:vm)

      expect {provider.destroy}.to raise_error(/undefined method `Destroy_Task' for nil/)
    end
  end

  context "#is_internal_nfs_datastore?" do
    it "should return true when name starts with _nfs_asm" do
      expect(provider.is_internal_nfs_datastore?("_nfs_asm_vm1")).to be_truthy
    end

    it "should return false otherwise" do
      expect(provider.is_internal_nfs_datastore?("gs4esx2-local-storage-1")).to be_falsey
    end
  end

  context "#is_local_datastore?" do
    it "should return true for local storage" do
      expect(provider.is_local_datastore?("gs4esx2-local-storage-1")).to be_truthy
    end

    it "should return true for DAS storage" do
      expect(provider.is_local_datastore?("DAS198374")).to be_truthy
    end

    it "should return false otherwise" do
      expect(provider.is_local_datastore?("_nfs_asm_gs4vm2")).to be_falsey
    end
  end

  context "#usable_datastore?" do
    let(:datastore) {{"name" => "generic-storage-1", "summary.accessible" => true}}

    it "should return false for internal NFS datastores" do
      expect(provider.usable_datastore?(datastore.merge("name" => "_nfs_asm_vm1"))).to be_falsey
    end

    it "should return false for inaccessible datastores" do
      expect(provider.usable_datastore?(datastore.merge("summary.accessible" => false))).to be_falsey
    end

    it "should return true for remote datastores" do
      expect(provider.usable_datastore?(datastore.merge("name" => "iscsi-storage-1"))).to be_truthy
    end

    it "should return true for local datastores unless `:skip_local_datastore`" do
      provider.resource[:skip_local_datastore] = :false
      expect(provider.usable_datastore?(datastore.merge("name" => "gs4esx2-local-storage-1"))).to be_truthy
    end

    it "should return false for local datastores if `:skip_local_datastore`" do
      provider.resource[:skip_local_datastore] = :true
      expect(provider.usable_datastore?(datastore.merge("name" => "gs4esx2-local-storage-1"))).to be_falsey
    end
  end

  context "datastore sorting" do
    let(:pods) {
      [
          {"name" => "pod-storage-1",
           "pod" => true,
           "info" => mock("pod-storage-1_info"),
           "summary" => mock("pod-storage-1_summary"),
           "summary.capacity" => 591363309568,
           "summary.freeSpace" => 564766179328,
           "free" => 564766179328,
           "summary.accessible" => true},
          {"name" => "pod-storage-2",
           "pod" => true,
           "info" => mock("pod-storage-1_info"),
           "summary" => mock("pod-storage-1_summary"),
           "summary.capacity" => 591363309568,
           "summary.freeSpace" => 179328,
           "free" => 179328,
           "summary.accessible" => true}
      ]
    }

    let(:datastores) {
      [
          {"name" => "iscsi-storage-1",
           "iscsi" => true,
           "info" => mock("iscsi-storage-1_info"),
           "summary" => mock("iscsi-storage-1_summary"),
           "summary.capacity" => 591363309568,
           "summary.freeSpace" => 564766179328,
           "summary.accessible" => true},
          {"name" => "iscsi-storage-2",
           "iscsi" => true,
           "info" => mock("iscsi-storage-2_info"),
           "summary" => mock("iscsi-storage-2_summary"),
           "summary.capacity" => 591363309568,
           "summary.freeSpace" => 179328,
           "summary.accessible" => true},
          {"name" => "iscsi-storage-inaccessible",
           "iscsi" => true,
           "info" => mock("iscsi-storage-inaccessible_info"),
           "summary" => mock("iscsi-storage-inaccessible_summary"),
           "summary.capacity" => 591363309568,
           "summary.freeSpace" => 179328,
           "summary.accessible" => false},
          {"name" => "gs4esx2-local-storage-1",
           "info" => mock("gs4esx2-local-storage-1_info"),
           "summary" => mock("gs4esx2-local-storage-1_summary"),
           "summary.capacity" => 591363309568,
           "summary.freeSpace" => 564766179328,
           "summary.accessible" => true},
          {"name" => "gs4esx2-local-storage-2",
           "info" => mock("gs4esx2-local-storage-2_info"),
           "summary" => mock("gs4esx2-local-storage-2_summary"),
           "summary.capacity" => 591363309568,
           "summary.freeSpace" => 98347987,
           "summary.accessible" => true},
          {"name" => "_nfs_asm_gs5vm1",
           "info" => mock("_nfs_asm_gs5vm1_info"),
           "summary" => mock("_nfs_asm_gs5vm1_summary"),
           "summary.capacity" => 52710469632,
           "summary.freeSpace" => 45187215360,
           "summary.accessible" => false}]
    }

    context "#prioritized_datastores" do
      it "should order by pods, remote, then local datastores" do
        provider.expects(:get_cluster_storage_pods).returns(pods.sort_by {rand})

        prioritized = provider.prioritized_datastores(datastores.sort_by {rand})

        expected = (pods + datastores.reject {|d| !d["summary.accessible"]}).map {|d| d["name"]}

        expect(prioritized.map {|d| d["name"]}).to eq(expected)
      end

      it "not require pods" do
        provider.expects(:get_cluster_storage_pods).returns([])

        prioritized = provider.prioritized_datastores(datastores.sort_by {rand})

        expected = datastores.reject {|d| !d["summary.accessible"]}.map {|d| d["name"]}

        expect(prioritized.map {|d| d["name"]}).to eq(expected)
      end
    end

    context "#get_cluster_datastore" do
      let(:retriever) {mock("RetrieveProperties")}
      let(:vim) {mock(:propertyCollector => retriever)}
      let(:cluster) {mock(:datastore => [])}

      before(:each) do
        provider.stubs(:vim).returns(vim)
        provider.stubs(:cluster).returns(cluster)
      end

      it "should return the best datastore" do
        provider.resource[:datastore] = "" # pick it instead
        retriever.expects(:RetrieveProperties).returns(datastores)
        provider.expects(:get_cluster_storage_pods).returns([])

        expect(provider.get_cluster_datastore["name"]).to eq("iscsi-storage-1")
      end

      it "should return the requested datastore" do
        provider.resource[:datastore] = "gs4esx2-local-storage-1"
        retriever.expects(:RetrieveProperties).returns(datastores)
        provider.expects(:get_cluster_storage_pods).returns([])

        expect(provider.get_cluster_datastore["name"]).to eq("gs4esx2-local-storage-1")
      end

      it "should fail if the requested datastore is not found" do
        retriever.expects(:RetrieveProperties).returns(datastores)
        provider.expects(:get_cluster_storage_pods).returns([])

        expect {provider.get_cluster_datastore}.to raise_error("Datastore gale-fsr not found")
      end

      it "should fail if no datastore is big enough" do
        provider.resource[:datastore] = "" # pick it instead
        provider.resource[:virtual_disks] = [{"size" => 500000}, {"size" => 500000}]

        retriever.expects(:RetrieveProperties).returns(datastores)
        provider.expects(:get_cluster_storage_pods).returns([])

        expect {provider.get_cluster_datastore}.to raise_error("No datastore found with sufficient free space")
      end
    end
  end
end
