require 'rbvmomi'
require 'puppet/modules/vcenter'
include Puppet::Modules::VCenter

Puppet::Type.type(:vc_datacenter).provide(:vc_datacenter) do
  @doc = "Manages vCenter datacenters."

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
    # dcname is the last part
    @dcname ||= @parent_lvs.pop
    @immediate_parent ||= find_immediate_parent
  end

  # return a Folder at @resource[:path]
  def find_immediate_parent
    Puppet::Modules::VCenter.find_immediate_parent(
                      @root_folder,
                      @parent_lvs,
                      "Invalid path for datacenter #{@resource[:path]}")
  end

  def self.instances
    # list all instances of datacenter in vCenter.
  end

  def create
    # TODO If there's a datacenter at any level in the path (not only
    # the immediate-parent level), this is not going to work due to the
    # rule of vcenter itself.  We can let vcenter report it or we can
    # report it ourselves.  Currently we leave it to vcenter.  The bad
    # thing about it is ensuring /folder/dc/folder/dc/ present is gonna
    # fail but ensuring its absence will succeed.
    @immediate_parent.CreateDatacenter :name => @dcname
  end

  def destroy
    dc = @immediate_parent.find @dcname
    dc.Destroy_Task.wait_for_completion if dc.is_a? RbVmomi::VIM::Datacenter
  end

  def exists?
    # verify if datacenter exists
    setup
    dc = @immediate_parent.find @dcname
    !!dc.is_a?(RbVmomi::VIM::Datacenter)
  end
end

