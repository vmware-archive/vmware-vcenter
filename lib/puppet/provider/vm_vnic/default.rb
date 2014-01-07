provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:vm_vnic).provide(:vm_vnic, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manage vNic configuration."
  # Adds the vnic.
  def create
    begin
      spec = RbVmomi::VIM.VirtualMachineConfigSpec({:deviceChange => [{
        :operation => :add,
        :device => device_spec}]})
	  Puppet.notice "Adding vnic "
      vm.ReconfigVM_Task(:spec => spec).wait_for_completion
    rescue Exception => exc
      Puppet.err(exc.message)
    end
  end

  # Removes the vnic.
  def destroy
    begin
      spec = RbVmomi::VIM.VirtualMachineConfigSpec({
        :deviceChange => [{
        :operation => :remove,
        :device => vnic
        }]
      })
      Puppet.notice "Removing vnic " + resource[:name]
      vm.ReconfigVM_Task(:spec => spec).wait_for_completion
    rescue Exception => exc
      Puppet.err(exc.message)
    end
  end

  # Check to see if vnic exists or not.
  def exists?
    vnic
  end

  # Get the portgroup.
  def portgroup
    vnic.backing.deviceName
  end

  # Attach the port group to the vNIC.
  def portgroup=(value)
    new_backing = RbVmomi::VIM.VirtualEthernetCardNetworkBackingInfo(
    :deviceName => value
    )
    vnic_new = vnic
    vnic_new.backing = new_backing
    spec = RbVmomi::VIM.VirtualMachineConfigSpec({
      :deviceChange => [{
      :operation => :edit,
      :device => vnic_new
      }]
    })
    vm.ReconfigVM_Task(:spec => spec).wait_for_completion
  end

  # Private methods.
  private
  def device_spec
     port_group =  resource[:portgroup]
     backing = RbVmomi::VIM.VirtualEthernetCardNetworkBackingInfo(
               :deviceName => port_group)
      if resource[:nic_type] == :E1000
       return RbVmomi::VIM.VirtualE1000({
          :key => 1,
          :deviceInfo => {
          :label => "Network Adapter",
          :summary => port_group
          },
          :backing => backing
        })
      elsif resource[:nic_type].to_s == "VMXNET 3"
        return RbVmomi::VIM.VirtualVmxnet3({
          :key => 1,
          :deviceInfo => {
          :label => "Network Adapter",
          :summary => port_group
          },
          :backing => backing
        })
      else
        return RbVmomi::VIM.VirtualVmxnet2({
          :key => 1,
          :deviceInfo => {
          :label => "Network Adapter",
          :summary => port_group
          },
          :backing => backing
        })
       
      end
  end

  def vnic
    dnic_arr = vm.config.hardware.device.grep(RbVmomi::VIM::VirtualEthernetCard)
    dnic_arr.each do |dnic|
      vnic_label = dnic.deviceInfo.label
      if vnic_label == resource[:name]
        return dnic
      end
    end
    return nil
  end

  def vm
    begin
      dc = vim.serviceInstance.find_datacenter(resource[:datacenter]) or  raise Puppet::Error, "Unable to find the data center. The data center with the specified name does not exist."
      @vmObj ||= dc.find_vm(resource[:vm_name]) or raise Puppet::Error, "Unable to find the Virtual Machine because the Virtual Machine does not exist."
    rescue Exception => excep
      Puppet.err excep.message
    end
  end

end