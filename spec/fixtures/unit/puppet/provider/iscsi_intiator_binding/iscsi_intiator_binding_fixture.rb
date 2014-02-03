class Iscsi_intiator_binding_fixture

  attr_accessor :iscsi_intiator_binding, :provider
  def initialize
    @iscsi_intiator_binding = intiator_binding
    @provider = iscsi_intiator_binding.provider
  end

  private

    def  intiator_binding
      Puppet::Type.type(:iscsi_intiator_binding).new(
          :name                      =>  '172.28.8.102: vmhba33',
          :vmknics                   =>  'vmk1',
          :script_executable_path    =>  '/usr/bin/esxcli',
          :host_username             =>  'root',
          :host_password             =>  'P@ssw0rd',
      )
    end    

end