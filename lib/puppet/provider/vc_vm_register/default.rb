provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:vc_vm_register).provide(:vc_vm_register, :parent => Puppet::Provider::Vcenter) do
  @doc = "Registers and unregisters vCenter Virtual Machines."
  def create
    Puppet.debug "******Inside create*************."
    Puppet.debug "Path: '"+resource[:vmpath_ondatastore]+"'."
    Puppet.debug "host: '"+resource[:hostip]+"'."
    Puppet.debug "name: '"+resource[:name]+"'."
    
    begin           
    host_view = vim.searchIndex.FindByIp(:datacenter => @dc , :ip => resource[:hostip], :vmSearch => false)      
    if !host_view
      raise Puppet::Error, "Unable to find the host '"+hostip+"'because the host is either invalid or does not exist."
    end
    
    asTemplate = resource[:astemplate]
    if asTemplate.to_s == 'true'        
      @dc.vmFolder.RegisterVM_Task(:name => resource[:name], :path => resource[:vmpath_ondatastore],
                                        :asTemplate => asTemplate, :host => host_view).wait_for_completion  
    else
       @dc.vmFolder.RegisterVM_Task(:name => resource[:name], :path => resource[:vmpath_ondatastore],
                                        :asTemplate => asTemplate, :host => host_view,
                                        :pool =>host_view.parent.resourcePool ).wait_for_completion
    end       
       
    rescue Exception => excep
      Puppet.err "Unable to register virtual machine because the following exception occurred."
      Puppet.err excep.message
    end

  end

  def destroy
    Puppet.debug "******Inside destroy*************."
    Puppet.debug "datacenter: '"+resource[:datacenter]+"'."
    Puppet.debug "vmname: '"+resource[:name]+"'."
    begin
    puts "vmobj:#{@vmObj}"
    if !@vmObj.config.template
      vmpower_state = @vmObj.runtime.powerState
      puts "vmpower_state: #{@vmpower_state}"
      if vmpower_state.eql?('poweredOn')
        Puppet.notice "Virtual Machine is in powered On state. Need to power it Off."
        @vmObj.PowerOffVM_Task.wait_for_completion
      end
    end
    
    @vmObj.UnregisterVM 
    rescue Exception => excep
      Puppet.err "Unable to unregister virtual machine because the following exception occurred."
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
      @vmObj = @dc.find_vm(resource[:name])        
    rescue Exception => excep
      Puppet.err excep.message
    end
  end
end
