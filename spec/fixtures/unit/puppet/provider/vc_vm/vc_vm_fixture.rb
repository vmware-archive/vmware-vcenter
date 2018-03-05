class Vc_vm_fixture

  attr_accessor :vc_vm, :provider
  def initialize
    @vc_vm = get_vc_vm
    @provider = vc_vm.provider
  end

  private

  def  get_vc_vm
    Puppet::Type.type(:vc_vm).new(
        :name => 'UbuntuCloneGuestVM',
        :datacenter => 'DDCQA',
        :memory_mb => '2048',
        :num_cpus => '2',
        :host => '172.16.100.56',
        :cluster => '',
        :datastore => 'gale-fsr',
        :disk_format => 'thin',

        :disk_size => '4096',
        :memory_hot_add_enabled => true,
        :cpu_hot_add_enabled => true,

        :guestid => 'winXPProGuest',

        :network_interfaces => [{:portgroup => 'VM network', :nic_type => 'vmxnet3'}],

        :domain => 'asm.test',
        :guest_customization => 'false'
        )
  end
 
  public
 def get_name
    vc_vm[:name]
  end
  
end