require 'rbvmomi'
require 'puppet/modules/vcenter'
include Puppet::Modules::VCenter

Puppet::Type.type(:vc_cluster).provide(:vc_cluster) do
  @doc = "Manages vCenter Clusters."

  def self.instances
    # list all instances of Clusters in vCenter.
  end

  def create
    # TODO Cluster spec?
    case
    when @immediate_parent.is_folder?
      # may report error if there's no Datacenter in the path
      @immediate_parent.real_container.CreateClusterEx(
        :name => @cluster_name, :spec => {})
    when @immediate_parent.is_datacenter?
      @immediate_parent.real_container.hostFolder.CreateClusterEx(
        :name => @cluster_name, :spec => {})
    when @immediate_parent.is_cluster?
      raise Puppet::Error.new("Invalid path for Cluster #{@resource[:path]}")
    else
      raise Puppet::Error.new('Unknown internal container type.')
    end
  end

  def destroy
    cluster = @immediate_parent.find_child_by_name(@cluster_name)
    if cluster.is_a?(RbVmomi::VIM::ClusterComputeResource)
      cluster.Destroy_Task.wait_for_completion
    else
      raise Puppet::Error.new("#{@resource[:path]} isn't a Cluster.")
    end
  end

  def exists?
    @cluster_name, parent_lvs = parse_path(@resource[:path])
    @immediate_parent ||= find_immediate_parent(
        @resource[:connection],
        parent_lvs,
        "Invalid path for Cluster #{@resource[:path]}")
    @immediate_parent.find_child_by_name(@cluster_name).instance_of?(RbVmomi::VIM::ClusterComputeResource)
  end
end

