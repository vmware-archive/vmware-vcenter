class Esx_mem_fixture

  attr_accessor :esx_mem, :provider
  def initialize
    @esx_mem = get_esx_mem
    @provider = esx_mem.provider
  end

  private

  def  get_esx_mem
    Puppet::Type.type(:esx_mem).new(
         :name             => '172.16.100.56',
		 :configure_mem    =>  'true',
		 :storage_groupip  =>  '192.168.110.3',
		 :iscsi_vmkernal_prefix   => 'iSCSI',
		 :vnics_ipaddress  => '192.168.110.10,192.168.110.11',
		 :iscsi_vswitch  => 'vSwitch3',
		 :iscsi_netmask  => '255.255.255.0',
		 :vnics  => 'vmnic1,vmnic2',
		 :iscsi_chapuser  => 'demoChap',
		 :iscsi_chapsecret  => 'demoChap',
		 :disable_hw_iscsi  => 'true',
		 :host_username  => 'root',
		 :host_password  => 'iforgot@123',
		 :script_executable_path  => '/usr/bin/perl',
		 :setup_script_filepath  => '/root/scripts/setup.pl'
    )
  end

end