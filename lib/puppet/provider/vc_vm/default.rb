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
      if vm.guest.toolsStatus == 'toolsNotInstalled'
        vm.PowerOffVM_Task.wait_for_completion
      else
        vm.ShutdownGuest.wait_for_completion
      end
    else
      vm.PowerOnVM_Task.wait_for_completion
    end
  end

  private

  def findvm(folder,vm_name)
    folder.children.each do |f|
      break if @vm_obj
      case f
      when RbVmomi::VIM::Folder
        findvm(f,vm_name)
      when RbVmomi::VIM::VirtualMachine
        @vm_obj = f if f.name == vm_name
      when RbVmomi::VIM::VirtualApp
        f.vm.each do |v|
          if v.name == vm_name
            @vm_obj = f
            break
          end
        end
      else
        puts "unknown child type found: #{f.class}"
        exit
      end
    end
    @vm_obj
  end

  def datacenter(name=resource[:datacenter_name])
    vim.serviceInstance.find_datacenter(name) or raise Puppet::Error, "datacenter '#{name}' not found."
  end

  def vm
    # findvm(datacenter.vmFolder,resource[:name])
    @vm ||= findvm(datacenter.vmFolder, resource[:name])
  end
end

