require 'pathname'
require 'rbvmomi' unless Puppet.run_mode.master?

class PathNotFoundError < Puppet::Error
end

class Puppet::Provider::Vcenter <  Puppet::Provider

  private
  # connect to vCenter and get the rootFolder.
  def get_root_folder(connection_url)
    # TODO: move this to a transport.
    user, pwd, host = connection_url.split(%r{[:@]})
    @conn = RbVmomi::VIM.connect(:host => host,
                                :user => user,
                                :password => pwd,
                                :insecure => true)
    @conn.serviceInstance.content.rootFolder
  end

  def rootfolder
    @rootfolder ||= get_root_folder(resource[:connection])
  end

  # Always return a folder
  def vmfolder(path=parent)
    if path == '/'
      vmfolder = rootfolder
    else
      vmfolder = locate(path)
    end
    raise PathNotFoundError.new("Invalid path: #{path}") unless vmfolder
    return_folder(vmfolder)
  end

  def return_folder(folder)
    case folder
    when RbVmomi::VIM::Folder
      folder
    when RbVmomi::VIM::Datacenter
      folder.hostFolder
    when RbVmomi::VIM::ClusterComputeResource
      folder
    else
      raise Puppet::Error.new("vmfolder unknown container type")
    end
  end

  def locate(path, type=nil)
    folder = rootfolder
    Pathname.new(path).each_filename do |dir|
      folder = return_folder(folder).traverse(dir)
    end

    if type
      folder if folder.is_a? type
    else
      folder
    end
  end

  def parent
    @parent ||= Pathname.new(resource[:path]).parent.to_s
  end

  def basename
    @basename ||= Pathname.new(resource[:path]).basename.to_s
  end
end
