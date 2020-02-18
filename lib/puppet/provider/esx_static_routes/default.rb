provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:esx_static_routes).provide(:esx_static_routes, :parent => Puppet::Provider::Vcenter) do
  @doc = "Set static routes for ESX"

  def create
    resource[:subnet_ip_addresses].each_with_index do |target_network_ip_addr, index|
      host.esxcli.network.ip.route.ipv4.add(:network => target_network_ip_addr, :gateway => resource[:gateways][index]) if @missing_routes.include? target_network_ip_addr
    end
  end

  def destroy
    resource[:subnet_ip_addresses].each_with_index do |target_network_ip_addr, index|
      host.esxcli.network.ip.route.ipv4.remove(:network => target_network_ip_addr, :gateway => resource[:gateways][index]) if @existing_routes.include? target_network_ip_addr
    end
  end

  def exists?
    @existing_routes = []
    @missing_routes = []

    Puppet.debug "Checking existing static routes on the host, %s." % resource[:host]

    current_routes = host.esxcli.network.ip.route.ipv4.list
    configured_networks = current_routes.map {|r| r[:Network]}

    resource[:subnet_ip_addresses].each do |target_network_ip_addr|
      if !configured_networks.include? target_network_ip_addr.split("/").first
        @missing_routes << target_network_ip_addr
      end
    end

    @missing_routes.empty?
  end
end
