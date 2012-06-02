Puppet::Type.type(:vc_datacenter).provide(:vc_datacenter) do
  require 'pathname' # WORK_AROUND #14073
  require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'modules/vcenter/provider_base'
  include Puppet::Modules::VCenter::ProviderBase

  @doc = "Manages vCenter Datacenters."

  def self.instances
    # list all instances of Datacenter in vCenter.
  end

  def create
    err_msg = "Invalid path for Datacenter #{@resource[:path]}"
    if @immediate_parent
      @immediate_parent.create_datacenter(@dcname, err_msg)
    else
      raise Puppet::Modules::VCenter::ProviderBase::PathNotFoundError.new(
        err_msg, __LINE__, __FILE__)
    end
  end

  def destroy
    @immediate_parent.destroy_child(@dcname,
                                    RbVmomi::VIM::Datacenter,
                                    "#{@resource[:path]} isn't a Datacenter.")
  end

  def exists?
    lvs = parse_path(@resource[:path])
    @dcname = lvs.pop
    parent_lvs = lvs
    begin
      @immediate_parent ||= find_immediate_parent(
          get_root_folder(@resource[:connection]),
          parent_lvs,
          "Invalid path for Datacenter #{@resource[:path]}")
      @immediate_parent.find_child_by_name(@dcname).instance_of?(
                                            RbVmomi::VIM::Datacenter)
    rescue Puppet::Modules::VCenter::ProviderBase::PathNotFoundError
      false
    end
  end
end

