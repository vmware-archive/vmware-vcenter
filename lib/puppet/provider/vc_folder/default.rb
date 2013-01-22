provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vc_folder).provide(:vc_folder, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter Folders."

  def create
    vmfolder.CreateFolder(:name => basename)
  end

  def destroy
    folder = locate(@resource[:path], RbVmomi::VIM::Folder)
    folder.Destroy_Task.wait_for_completion
  end

  def exists?
    locate(@resource[:path], RbVmomi::VIM::Folder)
  end
end

