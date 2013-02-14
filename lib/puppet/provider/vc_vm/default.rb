# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vc_vm).provide(:vc_vm, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter VMs."

  def create
    # TODO: Clone a VM from template.
    if resource[:clone]
      # The following code is not tested
      diskMoveType = nil

      if opts[:linked]
        deltaize_disks src
        diskMoveType = :moveChildMostDiskBacking
      end

      task = src.CloneVM_Task(:folder => folder,
                              :name => name,
                              :spec => {
                                :location => {
                                  :diskMoveType => diskMoveType,
                                  :host => opts[:host],
                                  :pool => opts[:pool],
                                },
                               :template => opts[:template],
                               :powerOn => opts[:power_on],
                              })
    else
      config = {
        :name     => name,
        :guestId  => resource[:guestid],
        :files    => { :vmPathName => resource[:datastore] },
        :numCPUs  => resource[:cpucount],
        :memoryMB => resource[:memory],
        :deviceChange => [
          {
            :operation => :add,
            :device    => VIM.VirtualCdrom(
              :key         => -2,
              :connectable => {
                :allowGuestControl => true,
                :connected         => true,
                :startConnected    => true,
              },
              :backing     => VIM.VirtualCdromIsoBackingInfo(:fileName => resource[:datastore] ),
              :controllerKey => 200,
              :unitNumber => 0
            )
          }
        ],
      }

      vmFolder.CreateVM_Task( :config => config,
                              :pool   => resource[:pool],
                              :host   => resource[:host]).wait_for_completion
    end
  end

  def destroy
    vm.Destroy_Task.wait_for_completion
  end

  def exists?
    vm
  end

  private

  def vm
    @vm = locate(File.join(resource[:path], resource[:name]), RbVmomi::VIM::VirtualMachine)
  end
end

