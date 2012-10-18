require 'pathname'
require 'lib/puppet/modules/vcenter/transport'

class Puppet::Provider::Vcenter <  Puppet::Provider

  private

  def self.transport(resource)
    name = Puppet::Resource.new(nil, resource[:transport].to_s).title
    trans = resource.catalog.resource(resource[:transport].to_s).to_hash
    Puppet::Modules::Vcenter::Transport.current(name) || Puppet::Modules::Vcenter::Transport.new(trans[:name], trans[:username], trans[:password], trans[:server])
  end

  def transport
    @transport ||= self.class.transport(resource)
  end

  def vim
    transport.vim
  end

  def rootfolder
    @rootfolder ||= vim.serviceInstance.content.rootFolder
  end

  # Always return a folder
  def vmfolder(path=parent)
    if path == '/'
      vmfolder = rootfolder
    else
      vmfolder = locate(path)
    end
    raise Pupept::Error.new("Invalid path: #{path}") unless vmfolder
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
    when NilClass
      raise Puppet::Error.new("Invalid path: #{@resource[:path]}.")
    else
      raise Puppet::Error.new("Unknown container type: #{folder.class}")
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
