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
    puts caller[0]
    puts "Inside the exists method."
    vm
  end

  # Get the power state.
  def power_state
    puts "Get the virtual machine power state."
    puts caller[0]
    begin
      # Did not use '.guest.powerState' since it only works if vmware tools are running.
      vm.runtime.powerState
    rescue Exception => e
      puts e.message
    end
  end

  # Set the power state.
  def power_state=(value)
    puts "Set the virtual machine power state."
    begin

      # perform operations if desired power_state=:poweredOff
      if value == :poweredOff
        if power_state != "poweredOff"
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
            if power_state != "poweredOff"
              vm.PowerOffVM_Task.wait_for_completion
            else
              puts "VM is already in poweredOff state."
            end
          end
        elsif power_state == "poweredOff"
          puts "VM is already in poweredOff state."
        end

        # perform operations if desired power_state=:poweredOn
      elsif value == :poweredOn
        if power_state != "poweredOn"
          vm.PowerOnVM_Task.wait_for_completion
        elsif power_state == "poweredOn"
          puts "VM is already in poweredOn state."
        end

        # perform operations if desired power_state=:suspend
      elsif value == :suspend
        if power_state != "poweredOff"
          vm.SuspendVM_Task.wait_for_completion
        elsif power_state == "poweredOff"
          puts "VM is already in poweredOff state."
        end

        # perform operations if desired power_state=:reset
      elsif value == :reset
        if power_state != "poweredOff"
          vm.ResetVM_Task.wait_for_completion
        else
          puts "Cannot reset VM  because it is not in poweredOn state."
        end

      end

    rescue Exception => e
      flag = 1
      puts "Exception occured with following message:"
      puts e.message
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
