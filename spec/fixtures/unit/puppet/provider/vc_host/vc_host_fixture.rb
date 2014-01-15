class Vc_host_fixture

  attr_accessor :vc_host, :provider
  def initialize
    @vc_host = get_vc_host
    @provider = vc_host.provider
  end

  private

  def  get_vc_host
    Puppet::Type.type(:vc_host).new(
    :name => 'esx1',
    :ensure    => 'present',
    :path      => '/dataceneter1/cluster1/',
    :username  => 'foo',
    :password  => 'bar'
    )
  end

end