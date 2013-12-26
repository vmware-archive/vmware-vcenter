provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'
Puppet::Type.type(:vc_vm_ovf).provide(:vc_vm_ovf, :parent => Puppet::Provider::Vcenter) do
  @doc = "Export Import OVF"
  
  def create
    #Import OVF.
    flag = 0
    ovf_filepath = resource[:ovffilepath]
    disk_format =  resource[:disk_format]
    vmname = resource[:name]
    begin
    # Getting transport Object to get vcenter credentials
	transport_obj = PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => resource[:transport], :catalog => resource.catalog, :provider => 'vsphere')
	vcenter_credentials = /:host=\>\"(\S+)\",\s+:user=\>\"(\S+)\",\s+:password=\>\"(\S+)\"/.match(transport_obj.inspect)	
	cmd = "ovftool --acceptAllEulas -ds="+resource[:target_datastore]+" -dm="+disk_format+" -n="+vmname+" "+ovf_filepath+" vi://"+vcenter_credentials[2]+":"+vcenter_credentials[3]+"@"+vcenter_credentials[1]+"/"+resource[:datacenter]+"/host"+"/"+resource[:host]
	system (cmd)
    if $? != 0 
        flag = 1
        Puppet.err "Failed to import OVF file '" + ovf_filepath+"'."
    end
    
    rescue Exception => exc
      Puppet.err(exc.message)
    end

    if flag != 1
        Puppet.notice "Virtual machine '" + vmname+"' created successfully."
       
    end
    end
  
  def destroy
    #Export OVF.
    flag = 0
    vmname = resource[:name]
    ovf_filepath = resource[:ovffilepath]
    begin
    # Getting transport Object to get vcenter credentials
	transport_obj = PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => resource[:transport], :catalog => resource.catalog, :provider => 'vsphere')
	vcenter_credentials = /:host=\>\"(\S+)\",\s+:user=\>\"(\S+)\",\s+:password=\>\"(\S+)\"/.match(transport_obj.inspect)		
	cmd = "ovftool --acceptAllEulas vi://"+vcenter_credentials[2]+":"+vcenter_credentials[3]+"@"+vcenter_credentials[1]+"/"+resource[:datacenter]+"/vm/"+vmname+" "+ovf_filepath	
	output = system (cmd)
   if $? != 0 
        flag = 1
        Puppet.err "Failed to export Virtual Machine '" + vmname+"' OVF file."
    end
     rescue Exception => exc
      flag = 1
      Puppet.err(exc.message)
    end
    if flag != 1
        Puppet.notice "OVF file exported successfully at '" + ovf_filepath+"' location."
    end
    
  end

def exists?
    vm
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
