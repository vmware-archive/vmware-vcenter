class Esx_portgroup_fixture

  attr_accessor :esx_portgroup, :provider
  def initialize
    @esx_portgroup = get_esx_portgroup
    @provider = esx_portgroup.provider
  end

  private

  def  get_esx_portgroup
    Puppet::Type.type(:esx_portgroup).new(
    :name => "172.16.100.56:test05",
    :ensure => 'present',
    :portgrouptype => "VMkernel",
    :overridefailback => "Enabled",
    :failback => "false",
    :mtu => "2019",
    :overridefailoverorder => "Enabled",
    :nicorderpolicy => {
      :activenic => ["vmnic1"],
      :standbynic => ["vmnic2"]
    },
    :overridecheckbeacon => "Enabled",
    :checkbeacon    => "true",
    :vmotion => "Enabled",
    :ipsettings => "static",
    :ipaddress => "172.16.104.52",
    :subnetmask => "255.255.255.0",
    :traffic_shaping_policy => "Enabled",
    :averagebandwidth => 5000,
    :peakbandwidth => 7027,
    :burstsize => 2085,
    :vswitch => 'vSwitch1',
    :path => "/Datacenter/Cluster01/",
    :vlanid => 1
    )
  end

end