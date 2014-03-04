class Vc_vm_fixture

  attr_accessor :vc_vm, :provider
  def initialize
    @vc_vm = get_vc_vm
    @provider = vc_vm.provider
  end

  private

  def  get_vc_vm
    Puppet::Type.type(:vc_vm).new(
       :name                         => 'UbuntuCloneGuestVM',
       :operation                      => 'create',
       :datacenter_name                => 'DDCQA',
       :memorymb                       => '2048',
       :numcpu                         => '2',
       :host                           =>'172.16.100.56',
       :cluster                        => '',
       :target_datastore               => 'gale-fsr',
       :diskformat                     => 'thin',      
     
       :disksize                       => '4096',
       :memory_hot_add_enabled         => true,
       :cpu_hot_add_enabled            => true,
     
        :guestid                      => 'winXPProGuest',
        :portgroup                     => 'VM network',
        :nic_count                     => '1',
        :nic_type                      => 'E1000',
   
     
       :goldvm                         => 'vShield Manager',
    
      
      
      :dnsDomain                       => 'asm.test',
      :guestCustomization              => 'false',
      :guesthostname                   => 'ClonedVM',
      :guesttype                       => 'linux',
      :linuxtimezone                   => 'EST',
      :windowstimezone                 => '035',
      :guestwindowsdomain              => '',
      :guestwindowsdomainadministrator => '',
      :guestwindowsdomainadminpassword => '',
      :windowsadminpassword            => 'iforgot',
      :productid  => '',
      :windowsguestowner               => 'TestOwner',
      :windowsguestorgnization         => 'TestOrg',
      :autologoncount                  => '',
      :autousers                       => '',
    )
  end
 
  public
 def get_name
    vc_vm[:name]
  end
  
end