Puppet::Type.type(:vc_folder).provide(:vc_folder) do
  require 'pathname' # WORK_AROUND #14073
  require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'modules/vcenter/provider_base'
  include Puppet::Modules::VCenter::ProviderBase

  @doc = "Manages vCenter Folders."

  def self.instances
    # list all instances of Folder in vCenter.
  end

  def create
    err_msg = "Invalid path for Folder #{@resource[:path]}"
    if @immediate_parent
      @immediate_parent.create_folder(@folder_name, err_msg)
    else
      raise Puppet::Modules::VCenter::ProviderBase::PathNotFoundError.new(
        err_msg, __LINE__, __FILE__)
    end
  end

  def destroy
    @immediate_parent.destroy_child(@folder_name,
                                    RbVmomi::VIM::Folder,
                                    "#{@resource[:path]} isn't a Folder.")
  end

  def exists?
    lvs = parse_path(@resource[:path])
    @folder_name = lvs.pop
    parent_lvs = lvs
    begin
      @immediate_parent ||= find_immediate_parent(
          get_root_folder(@resource[:connection]),
          parent_lvs,
          "Invalid path for Folder #{@resource[:path]}")
      @immediate_parent.find_child_by_name(@folder_name).instance_of?(
                                                  RbVmomi::VIM::Folder)
    rescue Puppet::Modules::VCenter::ProviderBase::PathNotFoundError
      false
    end
  end
end

