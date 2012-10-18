require 'lib/puppet/provider/vcenter'

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
    result = locate(@resource[:path])
    result.is_a? RbVmomi::VIM::Folder
  end
end

