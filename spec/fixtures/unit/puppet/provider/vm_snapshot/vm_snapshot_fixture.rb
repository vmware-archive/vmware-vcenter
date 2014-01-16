class Vm_snapshot_fixture

  attr_accessor :vm_snapshot, :provider
  def initialize
    @vm_snapshot = get_vm_snapshot
    @provider = vm_snapshot.provider
  end

  private

  def  get_vm_snapshot
    Puppet::Type.type(:vm_snapshot).new(
    :vm_name            => "testvm",
    :name               => "testsnapshot",
    :snapshot_operation => "create",
    :datacenter         => "DC1"
    )
  end

end