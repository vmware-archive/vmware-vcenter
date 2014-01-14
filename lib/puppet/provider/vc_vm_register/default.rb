provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:vc_vm_register).provide(:vc_vm_register, :parent => Puppet::Provider::Vcenter) do
  @doc = "Registers and removes vCenter Virtual Machines to/from inventory"
  def create

    begin
      host_view = get_host_view
      if !host_view
        raise Puppet::Error, "Unable to find the host it is either invalid or does not exist."
      end

      astemplate = get_template
      if astemplate.to_s == 'true'
        vm_register_as_template
      else
        vm_register
      end

    rescue Exception => excep
      Puppet.err "Unable to register virtual machine because the following exception occurred."
      Puppet.err excep.message
    end

  end

  def destroy

    begin
      power_off_vm_unregister
    rescue Exception => excep
      Puppet.err "Unable to remove virtual machine from inventory because the following exception occurred."
      Puppet.err excep.message
    end

  end

  def exists?
    vm
  end

  def get_host_view
    return  vim.searchIndex.FindByIp(:datacenter => vim.serviceInstance.find_datacenter(resource[:datacenter]) , :ip => resource[:hostip], :vmSearch => false)
  end

  def get_template
    return resource[:astemplate]
  end

  def vm_register_as_template
    Puppet.notice "The Virtual Machine is being registered as a template."
    dc_obj = vim.serviceInstance.find_datacenter(resource[:datacenter])
    dc_obj.vmFolder.RegisterVM_Task(:name => resource[:name], :path => resource[:vmpath_ondatastore],
    :asTemplate => astemplate, :host => host_view).wait_for_completion
  end

  def vm_register
    dc_obj = vim.serviceInstance.find_datacenter(resource[:datacenter])
    dc_obj.vmFolder..RegisterVM_Task(:name => resource[:name], :path => resource[:vmpath_ondatastore],
    :asTemplate => astemplate, :host => host_view,
    :pool =>host_view.parent.resourcePool ).wait_for_completion
  end

  def power_off_vm_unregister
    dc_obj = vim.serviceInstance.find_datacenter(resource[:datacenter])
    vm_obj = dc_obj.find_vm(resource[:name])
    if !vm_obj.config.template # check power state only if virtual machine is registered as a vm(not a template)
      vmpower_state = vm_obj.runtime.powerState
      Puppet.debug "vmpower_state: #{@vmpower_state}"
      if vmpower_state.eql?('poweredOn')
        Puppet.notice "The Virtual Machine is in Powered On state. It is required to Power Off the Virtual Machine before removing it from the inventory."
        vm_obj.PowerOffVM_Task.wait_for_completion
      end
    end
    vm_obj.UnregisterVM
  end

  private

  def vm
    begin
      @dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
      @vmfolder = @dc.vmFolder
      @vmObj = @dc.find_vm(resource[:name])
    rescue Exception => excep
      Puppet.err excep.message
    end
  end
end
