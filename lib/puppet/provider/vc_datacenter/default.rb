require 'rbvmomi'

Puppet::Type.type(:vc_datacenter).provide(:vc_datacenter) do
  @doc = "Manages vCenter datacenter."

  def setup
    # connect to vCenter.
    # TODO handle parsing errors (URI.parse?)
    user, pwd, host = @resource[:connection].split(%r{[:@]})
    @conn ||= RbVmomi::VIM.connect host: host,
                                   user: user,
                                   password: pwd,
                                   insecure: true
    @rootFolder = @conn.serviceInstance.content.rootFolder

    # TODO for now path must be in the form of '/foo/bar/dc/'
    @parent_path ||= @resource[:path][1..@resource[:path].size-2].split('/')
    # dcname is the last part
    @dcname ||= @parent_path.pop
    @immediate_parent ||= findImmediateParent
  end

  # return a Folder
  def findImmediateParent
    current_lv = @rootFolder
    @parent_path.each do |lv|
      # TODO ASSUMPTION each level is either a Folder (has a find method)
      # or a Datacenter (.hostFolder has a find method)

      # under the above assumption, if current_lv is doesn't have a find
      # method, we actually want its hostFolder
      current_lv = current_lv.hostFolder if !current_lv.class.method_defined? 'find'
      # go one level deeper
      current_lv = current_lv.find lv
      raise Puppet::Error.new('Invalid path for datacenter' + @resource[:path]) if !current_lv
    end
    raise Puppet::Error.new('The immediate parent of a datacenter can\'t be a Datacenter.') if current_lv.is_a? RbVmomi::VIM::Datacenter
    return current_lv
  end

  def self.instances
    # list all instances of datacenter in vCenter.
  end

  def create
    # create vCenter datacenter resource[:path]
    setup
    @immediate_parent.CreateDatacenter name: @dcname
  end

  def destroy
    # delete vCenter datacenter resource[:path]
    setup
    # TODO make sure @dcname is a Datacenter!
    @immediate_parent.find(@dcname).Destroy_Task.wait_for_completion
  end

  def exists?
    # verify if datacenter exists
    setup
    # TODO make sure @dcname is a Datacenter!
    return @immediate_parent.find @dcname
  end
end
