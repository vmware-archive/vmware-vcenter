class Esx_vswitch_fixture

  attr_accessor :esx_vswitch, :provider
  def initialize
    @esx_vswitch = get_esx_vswitch
    @provider = esx_vswitch.provider
  end

  private

  def  get_esx_vswitch
    Puppet::Type.type(:esx_vswitch).new(
    :name => "esx1:vSwitch1",
    :ensure         => 'present',
    :path           => "/datacenter1",
    :num_ports      => 1024,
    :nics           => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"],
    :nicorderpolicy => {
      activenic  => ["vmnic1", "vmnic4"],
      standbynic => ["vmnic3", "vmnic2"]
    },
    :mtu            => 5000,
    :checkbeacon    => false
    )
  end

end