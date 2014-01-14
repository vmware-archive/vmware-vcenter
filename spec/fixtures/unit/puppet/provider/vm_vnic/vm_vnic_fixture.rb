class Vm_vnic_fixture

  attr_accessor :vm_vnic, :provider
  def initialize
    @vm_vnic = get_vm_vnic
    @provider = vm_vnic.provider
  end

  private

  def  get_vm_vnic
    Puppet::Type.type(:vm_vnic).new(
    :name => 'Network adapter 1',
    :ensure => 'present',
    :vm_name => 'testVm',
    :portgroup => 'PortgroupName',
    :nic_type => 'E1000',
    :datacenter => "DatacenterName"
    )
  end

end