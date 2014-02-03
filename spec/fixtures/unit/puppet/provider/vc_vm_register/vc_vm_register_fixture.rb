class Vc_vm_register_fixture

  attr_accessor :vc_vm_register, :provider
  def initialize
    @vc_vm_register = get_vc_vm_register
    @provider = vc_vm_register.provider
  end

  private

  def  get_vc_vm_register
    Puppet::Type.type(:vc_vm_register).new(
        :name               => 'testVM_1',
        :datacenter         => 'DDCQA',
        :hostip             => '172.16.100.56',
        :astemplate         => 'true',
        :vmpath_ondatastore => '[gale-fsr] QA1/QA1.vmtx',
    )
  end
 
  public
 def get_register_vm_name
    vc_vm_register[:name]
  end
  def get_astemplate_true
    vc_vm_register[:astemplate] = 'true'
  end
  def get_astemplate_false
      vc_vm_register[:astemplate] = 'false'
   end
  
end