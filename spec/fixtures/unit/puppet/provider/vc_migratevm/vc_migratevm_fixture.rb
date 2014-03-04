class Vc_migratevm_fixture

  attr_accessor :vc_migratevm, :provider
  def initialize
    @vc_migratevm = migrate_vm
    @provider = vc_migratevm.provider
  end

  private

    def  migrate_vm
      Puppet::Type.type(:vc_migratevm).new(
      :name                     => 'testVM_1',
      :datacenter               => 'DDCQA',
      :disk_format              => 'thin',
      :migratevm_host           => '172.16.100.56', 
      :migratevm_datastore      => 'datastore1',
      :migratevm_host_datastore => '172.16.100.56, datastore3',
      )
    end    

end