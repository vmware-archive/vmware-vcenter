require 'lib/puppet/provider/vcenter'

# TODO: not sure if it makes sense writting this as different providers.
Puppet::Type.type(:esx_datastore).provide(:nfs, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter CIFS/NFS datastore."

  # a lame way to enforce default.
  defaultfor :true => true

  has_features :remote

  def create
    volume = {
      :remoteHost => resource[:remotehost],
      :remotePath => resource[:remotepath],
      :localPath  => resource[:localpath],
      :accessMode => resource[:accessmode],
    }

    case resource[:type]
    when 'NFS'
      host.configManager.datastoreSystem.CreateNasDatastore(:spec => volume)
    when 'CIFS'
      volume[:type] = 'CIFS'
      volume[:username] = resource[:username] if resource[:username]
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

  def remotehost
    @datastore.info.nas.remoteHost
  end

  def remotepath
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
