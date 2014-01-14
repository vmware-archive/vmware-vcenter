provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:vc_vm_ovf).provide(:vc_vm_ovf, :parent => Puppet::Provider::Vcenter) do
  @doc = "Export and Import OVF from vm"
  def create
    #Import OVF.
    begin
      flag = importovf
      if flag != 1
           Puppet.notice "Successfully created the Virtual Machine #{resource[:name]}."
      else
        Puppet.err "Unable to import the OVF file #{resource[:ovffilepath]}."
      end
    rescue Exception => exc
      Puppet.err(exc.message)
    end   
  end

  def destroy
    #Export OVF.  
    begin
      flag = exportovf
      if flag != 1
           Puppet.notice "Successfully exported the OVF file at #{resource[:ovffilepath]} location."
      else
        Puppet.err "Unable to export the Virtual Machine #{resource[:name]} OVF file."
      end
    rescue Exception => exc     
      Puppet.err(exc.message)
    end
end

  def exists?
    vm
  end
  

  def importovf
    flag = 0
    disk_format =  resource[:disk_format]
    # Getting transport Object to get vcenter credentials
    transport_obj = PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => resource[:transport], :catalog => resource.catalog, :provider => 'vsphere')
    vcenter_credentials = /:host=\>\"(\S+)\",\s+:user=\>\"(\S+)\",\s+:password=\>\"(\S+)\"/.match(transport_obj.inspect)
    cmd = "ovftool --acceptAllEulas -ds=#{resource[:target_datastore]} -dm=#{disk_format} -n=#{resource[:name]} #{resource[:ovffilepath]} vi://#{vcenter_credentials[2]}:#{vcenter_credentials[3]}@#{vcenter_credentials[1]}/#{resource[:datacenter]}/host/#{resource[:host]}"
puts cmd   
   system (cmd)
    if $? != 0
      flag = 1
    end
    return flag
  end

  def exportovf
    flag = 0
    # Getting transport Object to get vcenter credentials
    transport_obj = PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => resource[:transport], :catalog => resource.catalog, :provider => 'vsphere')
    vcenter_credentials = /:host=\>\"(\S+)\",\s+:user=\>\"(\S+)\",\s+:password=\>\"(\S+)\"/.match(transport_obj.inspect)
    cmd = "ovftool --acceptAllEulas vi://#{vcenter_credentials[2]}:#{vcenter_credentials[3]}@#{vcenter_credentials[1]}/#{resource[:datacenter]}/vm/#{resource[:name]} #{resource[:ovffilepath]}"
    output = system (cmd)
    if $? != 0
      flag = 1
    end
    return flag
  end


  private

  def vm
    begin
      dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
      @vmObj ||= dc.find_vm(resource[:name])
    rescue Exception => excep
      Puppet.err excep.message
    end
    return @vmObj
  end

end
