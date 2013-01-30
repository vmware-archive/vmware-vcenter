require 'puppet/provider/vshield'

Puppet::Type.type(:vshield_dns).provide(:default, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShield dns service.'

  def dns_servers
    @edge_dns = nested_value(get("/api/3.0/edges/#{vshield_scope_moref}/dns/config"), [ 'dns' ] )
    # set a blank array for dnsServers if it does not exist 
    @edge_dns['dnsServers'] = {} if not @edge_dns['dnsServers']
    @edge_dns['dnsServers']['ipAddress'] = ensure_array(@edge_dns['dnsServers']['ipAddress'])
    @edge_dns['dnsServers']['ipAddress'].sort
  end

  def dns_servers=(servers=resource[:dns_servers])
    @pending_changes = true
  end

  def enabled
    @edge_dns['enabled'].to_s
  end

  def enabled=(enable=resource[:enabled])
    @pending_changes = true
  end

  def flush
    if @pending_changes
      raise Puppet::Error, "Dns Settings not found for #{resource[:name]}" unless @edge_dns
      @edge_dns['dnsServers']['ipAddress'] = resource[:dns_servers]
      @edge_dns['enabled']                 = 'true'
      data                                 = {}
      data[:dns]                           = @edge_dns.reject{|k,v| v.nil? }
      
      Puppet.debug("Updating dns settings for edge: #{resource[:name]}")
      put("api/3.0/edges/#{vshield_scope_moref}/dns/config", data )
    end
  end
end
