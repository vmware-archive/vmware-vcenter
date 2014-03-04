class Esx_datastore_fixture

  attr_accessor :esx_datastore, :provider
  def initialize
    @esx_datastore = get_esx_datastore
    @provider = esx_datastore.provider
  end

  private

  def  get_esx_datastore
    Puppet::Type.type(:esx_datastore).new(
	     :ensure   => 'present',
         :name     => '172.16.100.56:newDS',
         :type     => 'vmfs',
         :lun      => 100
    )
  end
end