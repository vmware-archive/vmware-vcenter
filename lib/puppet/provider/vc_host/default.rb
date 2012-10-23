require 'lib/puppet/provider/vcenter'

Puppet::Type.type(:vc_host).provide(:vc_host, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter hosts."

  def create
    sslThumbprint = resource[:sslthumbprint]
    retry_attempt = 0

    begin
      spec = {
        :force         => true,
        :hostName      => resource[:name],
        :userName      => resource[:username],
        :password      => resource[:password],
        :sslThumbprint => sslThumbprint,
      }

      vmfolder(resource[:path]).AddStandaloneHost_Task(:spec => spec, :addConnected => true).wait_for_completion
    rescue RbVmomi::VIM::SSLVerifyFault
      unless resource[:secure]
        sslThumbprint = $!.fault.thumbprint
        Puppet.debug "Trusting insecure SSL Thumbprint: #{sslThumbprint}"
        retry_attempt += 1
        retry if retry_attempt <= 1
      end
      raise
    end
  end

  def destroy
    @host.Destroy_Task.wait_for_completion
  end

  # TODO: implement real path checking.
  def path
    resource[:path]
  end

  def path=(value)
  end

  def exists?
    find_host ? true : false
  end

  private

  def walk_dc(path=resource[:path])
    @datacenter = walk(path, RbVmomi::VIM::Datacenter)
    raise Puppet::Error.new( "No datacenter in path: #{path}") unless @datacenter
    @datacenter
  end

  def find_host
    @host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:name], :vmSearch => false)
  end
end

