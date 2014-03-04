class Vc_vm_ovf_fixture

  attr_accessor :vc_vm_ovf, :provider
  def initialize
    @vc_vm_ovf = get_vc_vm_ovf
    @provider = vc_vm_ovf.provider
  end

  private

  def  get_vc_vm_ovf
    Puppet::Type.type(:vc_vm_ovf).new(
         :name           => 'testVM_1',
         :ovffilepath      => '/root/OVF/test_123.ovf',
         :datacenter       => 'DDCQA',
         :target_datastore => 'datastore3',
         :host             => '172.16.100.56',
         :disk_format      => 'thin',
    )
  end
 
  public
 def get_ovf_name
    vc_vm_ovf[:ovffilepath]
  end
  
end