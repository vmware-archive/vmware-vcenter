require 'puppet/provider/vshield'

Puppet::Type.type(:vshield_ipset).provide(:default, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShield ipset.'

  def scope_moref
    @scope_moref ||= case resource[:scope_type]
                     when :datacenter
                       datacenter_moref(resource[:scope_name])
                     when :edge
                       edges = edge_summary || []
                       instance = edges.find{|x| x['name'] == resource[:scope_name]}
                       raise Puppet::Error, "vShield Edge #{resource[:scope_name]} does not exist." unless instance
                       instance['id']
                     else
                       raise Puppet::Error, "Unknown scope type #{resource[:scope_type]}"
                     end
  end

  def exists?
    results = nested_value(get("/api/2.0/services/ipset/scope/#{scope_moref}"), ['list', 'ipset'])

    # If there's a single ipset the result is a hash, while multiple results in an array.
    @ipset = [results].flatten.find {|ipset| ipset['name'] == resource[:name]}
  end

  def create
    data = {
      :revision => 0,
      :name     => resource[:name],
      :value    => resource[:value].sort.join(',')
    }
    post("api/2.0/services/ipset/#{@scope_moref}", {:ipset => data} )
  end

  def destroy
    delete("api/2.0/services/ipset/#{@ipset['objectId']}")
  end

  def value
    @ipset['value'].split(',').sort
  end

  def value=(ips)
    data = @ipset.clone
    # requires us to increment revision number, thing to try in future is omitting revision key
    data['revision'] = Integer(data['revision']) + 1
    data['value']    = resource[:value].sort.join(',')
    # get rid of nil value hash elements
    data = data.reject{|k,v| v.nil?}

    put("api/2.0/services/ipset/#{@ipset['objectId']}", {:ipset => data} )
  end

end
