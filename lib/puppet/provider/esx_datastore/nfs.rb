# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_datastore).provide(:nfs, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter CIFS/NFS datastore."

  # a lame way to enforce default.
  defaultfor :true => true

  has_features :remote

  def create

    volume = {}
    [:remote_host, :remote_path, :local_path, :access_mode].each do |prop|
      volume[PuppetX::VMware::Util.camelize(prop, :lower).to_sym] = resource[prop]
    end

    case resource[:type]
    when 'NFS'
      host.configManager.datastoreSystem.CreateNasDatastore(:spec => volume)
    when 'CIFS'
      volume[:type] = 'CIFS'
      volume[:userName] = resource[:user_name] if resource[:user_name]
      volume[:password] = resource[:password] if resource[:password]
      host.configManager.datastoreSystem.CreateNasDatastore(:spec => volume)
    end
  end

  def destroy
    host.configManager.datastoreSystem.RemoveDatastore(:datastore => @datastore)
  end

  def type
    @datastore.summary.type
  end

  def type=(value)
    warn "Can not change resource type."
  end

  def remote_host
    @datastore.info.nas.remoteHost
  end

  def remote_path
    @datastore.info.nas.remotePath
  end

  def exists?
    @datastore = host.datastore.find{|d|d.name==resource[:datastore]}
  end

  private

  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
  end
end
