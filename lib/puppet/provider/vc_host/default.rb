require 'rbvmomi'
require 'puppet/modules/vcenter'
include Puppet::Modules::VCenter

Puppet::Type.type(:vc_host).provide(:vc_host) do
  @doc = "Manages vCenter hosts."

  def connect
    # connect to vCenter.
    # FIXME handle parsing errors (URI.parse?)
    user, pwd, host = @resource[:connection].split(%r{[:@]})
    @conn ||= RbVmomi::VIM.connect :host => host,
                                   :user => user,
                                   :password => pwd,
                                   :insecure => true
    @root_folder ||= @conn.serviceInstance.content.rootFolder

    @hostname ||= @resource[:name]
    @username ||= @resource[:username]
    @password ||= @resource[:password]
  end

  # return a Folder at @resource[:path]
  def get_should_immediate_parent
    # FIXME @resource[:path] must be in the form of '/foo/bar/'
    parent_lvs = @resource[:path][1..@resource[:path].size-2].split('/')
    Puppet::Modules::VCenter.find_immediate_parent(
                    @root_folder,
                    parent_lvs,
                    "Invalid path for host #{@resource[:path]}")
  end

  # recursively traverse the tree
  # if the host is found
  #   @existing_host = the host (a ComputeResource object)
  #   @existing_path = the path (a string)
  # else
  #   @existing_host = nil
  #   @existing_path = nil
  def find_host folder
    host, path = find_host_aux folder
    if host
      @existing_host, @existing_path = host, "/#{path}"
    else
      @existing_host, @existing_path = nil, nil
    end
  end

  # recursion helper for find_host
  def find_host_aux folder
    # TODO consider only datacenters and folders for now, not clusters
    folder.children.each do |child|
      case
        when child.is_a?(RbVmomi::VIM::Datacenter)
          host, path = find_host_aux child.hostFolder
          return host, "#{child.name}/#{path}" if host
        when child.is_a?(RbVmomi::VIM::Folder)
          host, path = find_host_aux child
          return host, "#{child.name}/#{path}" if host
        when child.is_a?(RbVmomi::VIM::ComputeResource)
          # TODO ComputeResource may not always be a host!
          return child, '' if child.name == @hostname
      end
    end
    return nil, nil
  end

  #def self.instances
    ## list all instances of datacenter in vCenter.
  #end

  def create
    # TODO security, force
    @should_immediate_parent ||= get_should_immediate_parent
    host_spec = { :force => true,
                  :hostName => @hostname,
                  :userName => @username,
                  :password => @password,
                  :sslThumbprint => nil }
    while true
      begin
        @should_immediate_parent.AddStandaloneHost_Task(
          :spec => host_spec,
          :addConnected => true).wait_for_completion
        break
      rescue RbVmomi::VIM::SSLVerifyFault
        host_spec[:sslThumbprint] = $!.fault.thumbprint
      end
    end
  end

  def destroy
    @existing_host.Destroy_Task.wait_for_completion
  end

  def path
    find_host @root_folder
    @existing_path
  end

  def path=(value)
    @should_immediate_parent ||= get_should_immediate_parent
    @should_immediate_parent.MoveIntoFolder_Task(
      :list => [@existing_host]).wait_for_completion
  end

  def exists?
    # verify if host exists
    connect
    find_host @root_folder
    !!@existing_host
  end
end

