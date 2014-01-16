class Esx_fcoe_fixture

  attr_accessor :esx_fcoe, :provider
  def initialize
    @esx_fcoe = get_esx_fcoe
    @provider = esx_fcoe.provider
  end

  private

  def  get_esx_fcoe
    Puppet::Type.type(:esx_fcoe).new(
         :name             => '172.28.7.3:vmnic1',
         :path             => '/AS1000DC',
         :host             => '172.28.7.3',
         :physical_nic     => 'vmnic1',
    )
  end

end