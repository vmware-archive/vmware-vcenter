# Copyright (C) 2013 VMware, Inc.
begin
  require 'puppet_x/puppetlabs/transport'
rescue LoadError => e
  require 'pathname' # WORK_AROUND #14073 and #7788
  vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
  require File.join vmware_module.path, 'lib/puppet_x/puppetlabs/transport'
end

begin
  require 'puppet_x/puppetlabs/transport/vsphere'
rescue LoadError => e 
  require 'pathname' # WORK_AROUND #14073 and #7788
  module_lib = Pathname.new(__FILE__).parent.parent.parent
  require File.join module_lib, 'puppet_x/puppetlabs/transport/vsphere'
end

begin
  require 'puppet_x/vmware/util'
rescue LoadError => e 
  require 'pathname' # WORK_AROUND #14073 and #7788
  module_lib = Pathname.new(__FILE__).parent.parent.parent
  vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
  require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
end

class Puppet::Provider::Vcenter <  Puppet::Provider
  confine :feature => :vsphere

  private

  def vim
    @transport ||= PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => resource[:transport], :catalog => resource.catalog, :provider => 'vsphere')
    @transport.vim
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
    raise Puppet::Error.new("Invalid path: #{path}") unless vmfolder
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
    when RbVmomi::VIM::ComputeResource
      folder.resourcePool
    when NilClass
      raise Puppet::Error.new("Invalid path: #{@resource[:path]}.")
    else
      raise Puppet::Error.new("Unknown container type: #{folder.class}")
    end
  end

  def findvm(folder)
    vms = []
    folder.children.each do |c|
      puts c.class
      case c
      when RbVmomi::VIM::Folder
        puts c
        vms += findvm(c)
      when RbVmomi::VIM::VirtualMachine
        vms << c
      end
    end
    vms
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

  def walk(path, type, order=:ascend)
    Pathname.new(path).send(order) do |folder|
      obj = vim.searchIndex.FindByInventoryPath({:inventoryPath => folder.to_s})
      return obj if obj.is_a? type
    end
  end

  def parent(path=resource[:path])
    Pathname.new(path).parent.to_s
  end

  def basename(path=resource[:path])
    Pathname.new(path).basename.to_s
  end

  def host(host=nil, path=nil, fail_if_not_found = true)
    @host ||= begin
      if resource.propertydefined?(:host)
        host = resource[:host]
      end
      if resource.propertydefined?(:path)
        path ||= resource[:path]
      end

      if path
        dc = walk(path, RbVmomi::VIM::Datacenter) or fail("No datacenter in path: #{path}")
        vim.searchIndex.FindByDnsName(:datacenter => dc, :dnsName => host, :vmSearch => false)
      elsif host =~ Resolv::IPv4::Regex
        vim.searchIndex.FindByIp(:ip => host, :vmSearch => false)
      else
        vim.searchIndex.FindByDnsName(:dnsName => host, :vmSearch => false)
      end
    end

    if fail_if_not_found && !@host
      fail('An invalid host name or IP address is entered. Enter the correct host name and IP address.')
    end
    @host
  end

end
