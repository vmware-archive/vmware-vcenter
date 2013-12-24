provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:vc_vm_register).provide(:vc_vm_register, :parent => Puppet::Provider::Vcenter) do
  @doc = "Registers and removes vCenter Virtual Machines to/from inventory"
  def create
    Puppet.debug "******Inside create*************."
        
    begin           
    host_view = vim.searchIndex.FindByIp(:datacenter => @dc , :ip => resource[:hostip], :vmSearch => false)      
    if !host_view
      raise Puppet::Error, "Unable to find the host '"+hostip+"'because the host is either invalid or does not exist."
    end
    
    astemplate = resource[:astemplate]
    if astemplate.to_s == 'true'   
      Puppet.notice "Registering virtual machine as a template."        
      @vmfolder.RegisterVM_Task(:name => resource[:name], :path => resource[:vmpath_ondatastore],
                                        :asTemplate => astemplate, :host => host_view).wait_for_completion  
    else
	    @vmfolder.RegisterVM_Task(:name => resource[:name], :path => resource[:vmpath_ondatastore],
                                        :asTemplate => astemplate, :host => host_view,
                                        :pool =>host_view.parent.resourcePool ).wait_for_completion
    end       
       
    rescue Exception => excep
      Puppet.err "Unable to register virtual machine because the following exception occurred."
      Puppet.err excep.message
    end

  end

  def destroy
    Puppet.debug "******Inside destroy*************."
    	
    begin    
    if !@vmObj.config.template # check power state only if virtual machine is registered as a vm(not a template)
      vmpower_state = @vmObj.runtime.powerState
      Puppet.debug "vmpower_state: #{@vmpower_state}"
      if vmpower_state.eql?('poweredOn')
        Puppet.notice "Virtual Machine is in powered On state, need to power it Off before removing from inventory."
        @vmObj.PowerOffVM_Task.wait_for_completion
      end
    end    
    @vmObj.UnregisterVM 
    rescue Exception => excep
      Puppet.err "Unable to remove virtual machine from inventory because the following exception occurred."
      Puppet.err excep.message
    end 
   
  end

  def exists?
  Puppet.debug "******Inside exists*************."
    vm
  end

  private
  def vm
  Puppet.debug "******Inside vm*************."
    begin
      @dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
      @vmfolder = @dc.vmFolder
      @vmObj = @dc.find_vm(resource[:name])        
    rescue Exception => excep
      Puppet.err excep.message
    end
  end
end
