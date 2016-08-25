provider_path = Pathname.new(__FILE__).parent.parent
require 'rbvmomi'
require File.join(provider_path, 'vcenter')
require 'asm/util'

Puppet::Type.type(:esx_connection_wait).provide(:esx_connection_wait, :parent => Puppet::Provider::Vcenter) do
  @doc = "Wait for ESX host connection upto specified time-limit"

  def exists?
    false  # Force create to be invoked, or destroy to be ignored
  end

  def create
    wait_for_host(resource[:init_sleep], resource[:max_wait])
  end

end
