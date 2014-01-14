class Esx_get_iqns_fixture

  attr_accessor :esx_get_iqns, :provider
  def initialize
    @esx_get_iqns = get_esx_get_iqns
    @provider = esx_get_iqns.provider
  end

  private

  def  get_esx_get_iqns
    Puppet::Type.type(:esx_get_iqns).new(
      :host         => '172.16.100.56',
      :hostusername => 'root',
      :hostpassword => 'iforgot@123',
      
    )
  end
 
  public
 def get_host_name
   esx_get_iqns[:host]
  end
  
end