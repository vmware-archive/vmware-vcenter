class Esx_fc_multiple_path_config_fixture

  attr_accessor :esx_fc_multiple_path_config, :provider
  def initialize
    @esx_fc_multiple_path_config = get_esx_fc_multiple_path_config
    @provider = esx_fc_multiple_path_config.provider
  end

  private

  def  get_esx_fc_multiple_path_config
    Puppet::Type.type(:esx_fc_multiple_path_config).new(
    :host       => '172.28.10.3',
    :policyname => 'VMW_PSP_RR',
    :path       => "/AS1000DC/DDCCluster"
    )
  end

end