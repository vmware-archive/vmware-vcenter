Puppet::Type.type(:vc_cluster).provide(:vc_cluster) do
  require 'pathname' # WORK_AROUND #14073
  require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'modules/vcenter/provider_base'
  include Puppet::Modules::VCenter::ProviderBase

  @doc = "Manages vCenter Clusters."

  def self.instances
    # list all instances of Cluster in vCenter.
  end

  def create
    # TODO Cluster spec?
    err_msg = "Invalid path for Cluster #{@resource[:path]}"
    if @immediate_parent
      @immediate_parent.create_cluster(@cluster_name, err_msg)
    else
      raise Puppet::Modules::VCenter::ProviderBase::PathNotFoundError.new(
        err_msg, __LINE__, __FILE__)
    end
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
    begin
      @immediate_parent ||= find_immediate_parent(
          get_root_folder(@resource[:connection]),
          parent_lvs,
          "Invalid path for Cluster #{@resource[:path]}")
      @immediate_parent.find_child_by_name(@cluster_name).instance_of?(
                              RbVmomi::VIM::ClusterComputeResource)
    rescue Puppet::Modules::VCenter::ProviderBase::PathNotFoundError
      false
    end
  end
end

