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
    @immediate_parent.create_cluster(
        cluster_name,
        "Invalid path for Cluster #{@resource[:path]}")
  end

  def destroy
    @immediate_parent.destroy_child(@cluster_name,
                                    RbVmomi::VIM::ClusterComputeResource,
                                    "#{@resource[:path]} isn't a Cluster.")
  end

  def exists?
    lvs = parse_path(@resource[:path])
    @cluster_name = lvs.pop
    parent_lvs = lvs
    @immediate_parent ||= find_immediate_parent(
        get_root_folder(@resource[:connection]),
        parent_lvs,
        "Invalid path for Cluster #{@resource[:path]}")
    @immediate_parent.find_child_by_name(@cluster_name).instance_of?(RbVmomi::VIM::ClusterComputeResource)
  end
end

