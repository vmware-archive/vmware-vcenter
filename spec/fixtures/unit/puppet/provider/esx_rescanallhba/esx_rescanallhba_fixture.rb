class Esx_rescanallhba_fixture

  attr_accessor :esx_rescanallhba, :provider
  def initialize
    @esx_rescanallhba = get_esx_rescanallhba
    @provider = esx_rescanallhba.provider
  end

  private

  def  get_esx_rescanallhba
    Puppet::Type.type(:esx_rescanallhba).new(
    :host      => '172.16.103.95',
    :ensure    => 'present',
    :path      => "/AS1000DCTest123/asmcluster"
    )
  end

end