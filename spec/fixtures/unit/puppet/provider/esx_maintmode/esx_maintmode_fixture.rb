class Esx_maintmode_fixture

  attr_accessor :esx_maintmode, :provider
  def initialize
    @esx_maintmode = get_esx_maintmode
    @provider = esx_maintmode.provider
  end

  private

  def  get_esx_maintmode
    Puppet::Type.type(:esx_maintmode).new(
    :hostseq => '172.28.7.3:esx1'
    )
  end

end