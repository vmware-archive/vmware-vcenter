provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:vc_vsan_network).provide(:vc_vsan_network, :parent => Puppet::Provider::Vcenter) do
  @doc = "Enable / Disable VSAN property of vmkernel for each host in the cluster"

  def create
    vsan_hosts.each do |vsan_host|
      vmk_already_added = []
      cluster_host = vsan_host.hostSystem
      Puppet.debug("Processing cluster host %s" % [cluster_host.name])
      vmks = vsan_vmkernel(cluster_host).sort.uniq
      vsan_host_existing_vmk(vsan_host).each do |vmk_device|
        next if vmk_device.nil?
        vmk_already_added << vmk_device.device
      end

      Puppet.debug("VSAN VM kernels %s and VMKernels already added %s" % [vmks, vmk_already_added])
      if vmk_already_added.sort == vmks.sort
        Puppet.debug("All VSAN VMKernels are already configured for host %s" % [cluster_host.name])
        next
      end

      ports = []
      host_spec = []
      vmks.sort.each do |vmk|
        Puppet.debug("Creating new vsan network config: #{vmk}")
        ports << RbVmomi::VIM::VsanHostConfigInfoNetworkInfoPortConfig.new(:device => vmk)
      end

      network_info = RbVmomi::VIM::VsanHostConfigInfoNetworkInfo.new(:port => ports)
      host_spec << RbVmomi::VIM::VsanHostConfigInfo.new(:hostSystem => cluster_host, :networkInfo => network_info)
      spec = RbVmomi::VIM::ClusterConfigSpecEx.new(:vsanHostConfigSpec => host_spec)
      task_ref = cluster.ReconfigureComputeResource_Task(:modify => 'true', :spec => spec);
      task_ref.wait_for_completion
      raise("Failed to configure VSAN for host #{host.name}") unless task_ref.info.state == "success"
    end
  end

  def destroy
  end

  def exists?
    false
  end

  def datacenter
    @dc ||= vim.serviceInstance.find_datacenter(resource[:datacenter])
  end

  def cluster
    datacenter.find_compute_resource(resource[:cluster])
  end

  private

  def vsan_config_info
    cluster.configurationEx.vsanConfigInfo
  end

  def vsan_hosts
    cluster.configurationEx.vsanHostConfig
  end

  def cluster_hosts
    ( cluster.host || [] )
  end

  def vsan_host_existing_vmk(vsan_host)
    vsan_ports = ( vsan_host.networkInfo.port || [] )
    vsan_ports.collect { |x| x.device}
    Puppet.debug("VSAN Ports: #{vsan_ports}")
    vsan_ports
  end

  def vsan_vmkernel(host)
    vmks = []
    nicmgr = host.configManager.virtualNicManager.info.netConfig

    if resource[:vsan_dv_port_group_name] && resource[:vsan_dv_switch_name]
      dv_pg_names = Array(resource[:vsan_dv_port_group_name])
      dv_pg_names.each do |dv_pg_name|
        dv_pg = dvportgroup(resource[:vsan_dv_switch_name], dv_pg_name)
        Puppet.debug("Port name: #{dv_pg.name}")
        nicmgr.each do |n|
          n.candidateVnic.each do |nic|
            vmks << nic.device if nic.spec.distributedVirtualPort.portgroupKey == dv_pg.key
          end
        end
      end
    end

    if resource[:vsan_port_group_name]
      resource[:vsan_port_group_name].each do |pg|
        nicmgr.each do |n|
          n.candidateVnic.each do |nic|
            vmks << nic.device if nic.portgroup == resource[:vsan_port_group_name]
          end
        end
      end
    end
    vmks
  end

  def dvportgroup(dv_switch_name, dv_port_group_name)
    name = dv_port_group_name
    dvs_name = dv_switch_name
    pg =
        if datacenter
          pg =
              datacenter.networkFolder.children.select{|n|
                n.class == RbVmomi::VIM::DistributedVirtualPortgroup
              }.
                  find_all{|pg| pg.name == name}.
                  tap{|all| @dvportgroup_list = all}.
                  find{|pg| pg.config.distributedVirtualSwitch.name == dvs_name}
          if pg.nil? && (@dvportgroup_list.size != 0)
            owner = @dvportgroup_list.first.config.distributedVirtualSwitch.name
            fail "dvportgroup '#{name}' owned by dvswitch '#{owner}', "\
             "is not available for '#{dvs_name}'"
          end
          pg
        else
          nil
        end
    @pg = pg
  end


end
