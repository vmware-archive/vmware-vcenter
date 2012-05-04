require 'rbvmomi'
require 'puppet/modules/vcenter'
include Puppet::Modules::VCenter

Puppet::Type.type(:vc_folder).provide(:vc_folder) do
  @doc = "Manages vCenter folders."

  def setup
    # connect to vCenter.
    # FIXME handle parsing errors (URI.parse?)
    user, pwd, host = @resource[:connection].split(%r{[:@]})
    @conn ||= RbVmomi::VIM.connect :host => host,
                                   :user => user,
                                   :password => pwd,
                                   :insecure => true
    @root_folder ||= @conn.serviceInstance.content.rootFolder

    # FIXME for now path must be in the form of '/foo/bar/dc/'
    @parent_lvs ||= @resource[:path][1..@resource[:path].size-2].split('/')
    # folder name is the last part
    @folder_name ||= @parent_lvs.pop
    @immediate_parent ||= find_immediate_parent
  end

  # return a Folder at @resource[:path]
  def find_immediate_parent
    Puppet::Modules::VCenter.find_immediate_parent(
                      @root_folder,
                      @parent_lvs,
                      "Invalid path for folder #{@resource[:path]}")
  end

  def self.instances
    # list all instances of folder in vCenter.
  end

  def create
    @immediate_parent.CreateFolder :name => @folder_name
  end

  def destroy
    folder = @immediate_parent.find @folder_name
    folder.Destroy_Task.wait_for_completion if folder.is_a? RbVmomi::VIM::Folder
  end

  def exists?
    # verify if folder exists
    setup
    folder = @immediate_parent.find @folder_name
    !!folder.is_a?(RbVmomi::VIM::Folder)
  end
end

