require 'rbvmomi'
require 'puppet/modules/vcenter'
include Puppet::Modules::VCenter

Puppet::Type.type(:vc_datacenter).provide(:vc_datacenter) do
  @doc = "Manages vCenter Datacenters."

  def self.instances
    # list all instances of Datacenter in vCenter.
  end

  def create
    @immediate_parent.create_datacenter(
        @dcname,
        "Invalid path for Datacenter #{@resource[:path]}")
  end

  def destroy
    dc = @immediate_parent.find_child_by_name(@dcname)
    if dc.instance_of?(RbVmomi::VIM::Datacenter)
      dc.Destroy_Task.wait_for_completion 
    else
      raise Puppet::Error.new("#{@resource[:path]} isn't a Datacenter.")
    end
  end

  def exists?
    lvs = parse_path(@resource[:path])
    @dcname = lvs.pop
    parent_lvs = lvs
    @immediate_parent ||= find_immediate_parent(
        get_root_folder(@resource[:connection]),
        parent_lvs,
        "Invalid path for Datacenter #{@resource[:path]}")
    @immediate_parent.find_child_by_name(@dcname).instance_of?(RbVmomi::VIM::Datacenter)
  end
end

