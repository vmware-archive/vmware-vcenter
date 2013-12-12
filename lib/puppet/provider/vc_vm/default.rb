# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'
Puppet::Type.type(:vc_vm).provide(:vc_vm, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter VMs."
  puts  caller[0]
  def create
    # TODO: Clone a VM from template.
    puts "Inside Create Method."
    puts caller[0]
  end

  def destroy
    puts "Inside Destroy method."
    puts caller[0]
    vm.Destroy_Task.wait_for_completion
  end

  def exists?
    puts "Inside the exists method."
    vm
  end

  # Get the power state.
  def power_state
    puts "Get the virtual machine power state."
    # Did not use '.guest.powerState' since it only works if vmware tools are running.
    vm.runtime.powerState
  end
 
  # Set the power state.
  def power_state=(value)
      puts "Set the virtual machine power state."
      if value == :poweredOff
          if (vm.guest.toolsStatus != 'toolsNotInstalled') and resource[:graceful_shutdown] == :true
              vm.ShutdownGuest
              # Since vm.ShutdownGuest doesn't return a task we need to poll the VM powerstate before returning.
              attempt = 5  # let's check 5 times (1 min 15 seconds) before we forcibly poweroff the VM.
              while power_state != "poweredOff" and attempt > 0
                  sleep 15
                  attempt -= 1
              end
              vm.PowerOffVM_Task.wait_for_completion if power_state != "poweredOff"
          else
              vm.PowerOffVM_Task.wait_for_completion
          end
      elsif value == :poweredOn
          vm.PowerOnVM_Task.wait_for_completion if power_state != "poweredOn"
      elsif value == :suspend
          vm.SuspendVM_Task.wait_for_completion if power_state != "poweredOff"
      elsif value == :reset
          vm.ResetVM_Task.wait_for_completion if power_state != "poweredOff"
      end
  end

  private
  def vm
    puts "Inside the vm method."
    puts caller[0]
    dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
    puts resource[:name]
    @vmObj ||= dc.find_vm(resource[:name]) or abort "VM not found."
  end
end