require 'rbvmomi'

Puppet::Type.type(:vc_datacenter).provide(:vc_datacenter) do
  @doc = "Manages vCenter datacenter."

  def connection
    # some way to connect to vCenter.
  end

  def self.instances
    # list all instances of datacenter in vCenter.
  end

  def create
    # create vCenter datacenter resource[:path]
  end

  def destroy
    # delete vCenter datacenter resource[:path]
  end

  def exists?
    # verify if datacenter exists
  end
end
