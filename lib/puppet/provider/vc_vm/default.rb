# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vc_vm).provide(:vc_vm, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter VMs."

  def create
    Puppet.notice("Feature not implemented")
    # TODO: Clone a VM from template.
    #if resource[:clone]
      # The following code is not tested
    #  diskMoveType = nil

    #  if opts[:linked]
    #    deltaize_disks src
    #    diskMoveType = :moveChildMostDiskBacking
    #  end

    #  task = src.CloneVM_Task(:folder => folder,
    #                          :name => name,
    #                          :spec => {
    #                            :location => {
    #                              :diskMoveType => diskMoveType,
    #                              :host => opts[:host],
    #                              :pool => opts[:pool],
    #                            },
    #                           :template => opts[:template],
    #                           :powerOn => opts[:power_on],
    #                          })
    #else
    #  config = {
    #    :name     => name,
    #    :guestId  => resource[:guestid],
    #    :files    => { :vmPathName => resource[:datastore] },
    #    :numCPUs  => resource[:cpucount],
    #    :memoryMB => resource[:memory],
    #    :deviceChange => [
    #      {
    #        :operation => :add,
    #        :device    => VIM.VirtualCdrom(
    #          :key         => -2,
    #          :connectable => {
    #            :allowGuestControl => true,
    #            :connected         => true,
    #            :startConnected    => true,
    #          },
    #          :backing     => VIM.VirtualCdromIsoBackingInfo(:fileName => resource[:datastore] ),
    #          :controllerKey => 200,
    #          :unitNumber => 0
    #        )
    #      }
    #    ],
    #  }

    #  vmFolder.CreateVM_Task( :config => config,
    #                          :pool   => resource[:pool],
    #                          :host   => resource[:host]).wait_for_completion
    #end
  end

  def destroy
    # if the vm is not powered off, attempt to do so
    if vm.runtime.powerState != 'poweredOff'
      self.send(:power_state=, :poweredOff)
    end
    raise "vm: resource[:name] is not in the state: poweredOff" if vm.runtime.powerState != 'poweredOff'
    vm.Destroy_Task.wait_for_completion
  end

  def exists?
    vm
  end

  def power_state
    # did not use '.guest.powerState' since it only works if vmware tools are running
    vm.runtime.powerState
  end

  def power_state=(value)
    if value == :poweredOff
      if (vm.guest.toolsStatus != 'toolsNotInstalled') and resource[:graceful_shutdown] == :true
        vm.ShutdownGuest
        # Since vm.ShutdownGuest doesn't return a task we need to poll the VM powerstate before returning
        attempt = 12  # let's check 12 times (3 minutes) before we forcibly poweroff the VM
        while power_state != "poweredOff" and attempt > 0
          sleep 15
          attempt -= 1
        end
        vm.PowerOffVM_Task.wait_for_completion if power_state != "poweredOff"
      else
        vm.PowerOffVM_Task.wait_for_completion
      end
    else
      vm.PowerOnVM_Task.wait_for_completion
    end
  end

  private

  def datacenter(name=resource[:datacenter_name])
    vim.serviceInstance.find_datacenter(name) or raise Puppet::Error, "datacenter '#{name}' not found."
  end

  def vm
    # findvm(datacenter.vmFolder,resource[:name])
    @vm ||= findvm(datacenter.vmFolder, resource[:name])
  end
end

