Puppet::Type.type(:vc_host).provide(:vc_host) do
  require 'pathname' # WORK_AROUND #14073
  require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'modules/vcenter/provider_base'
  include Puppet::Modules::VCenter::ProviderBase

  @doc = "Manages vCenter hosts."

  # recursively traverse the tree
  # if the host is found
  #   @existing_host = the host (a ComputeResource object)
  #   @existing_path = the path (a string)
  # else
  #   @existing_host = nil
  #   @existing_path = nil
  def find_host(container)
    host, path = find_host_aux(container)
    if host
      @existing_host, @existing_path = host, "/#{path}"
    else
      @existing_host, @existing_path = nil, nil
    end
  end

  # recursion helper for find_host
  def find_host_aux(container)
    container.children.each do |child|
      if child.instance_of?(RbVmomi::VIM::ComputeResource) or child.instance_of?(RbVmomi::VIM::HostSystem)
        return child, '' if child.name == @hostname
      else
        host, path = find_host_aux(
          Puppet::Modules::VCenter::ProviderBase::Container.new(child))
        return host, "#{child.name}/#{path}" if host
      end
    end
    return nil, nil
  end

  def self.instances
    # list all instances of host in vCenter.
  end

  def create
    @username ||= @resource[:username]
    @password ||= @resource[:password]

    parent_lvs = parse_path(@resource[:path])
    @should_immediate_parent ||= find_immediate_parent(
        @root_folder,
        parent_lvs,
        "Invalid path for Host #{@resource[:path]}")
    # TODO security, force
    host_spec = { :force => true,
                  :hostName => @hostname,
                  :userName => @username,
                  :password => @password,
                  :sslThumbprint => nil }
    @should_immediate_parent.add_host(host_spec)
  end

  def destroy
    @existing_host.Destroy_Task.wait_for_completion
  end

  def path
    @existing_path
  end

  def path=(value)
    parent_lvs = parse_path(@resource[:path])
    @should_immediate_parent ||= find_immediate_parent(
        @root_folder,
        parent_lvs,
        "Invalid path for Host #{@resource[:path]}")
    @should_immediate_parent.move_host_into(@existing_host)
  end

  def exists?
    @hostname = @resource[:name]
    @root_folder = get_root_folder(@resource[:connection])
    find_host(Puppet::Modules::VCenter::ProviderBase::Container.new(@root_folder))
    !!@existing_host
  end
end

