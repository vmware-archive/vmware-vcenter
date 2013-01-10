require 'puppet/provider/vshield'

Puppet::Type.type(:vshield_application).provide(:default, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShield application.'

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
    results = nested_value(get("/api/2.0/services/application/scope/#{scope_moref}"), ['list', 'application'])
    # If there's a single application the result is a hash, while multiple results in an array.
    @application = [results].flatten.find {|application| application['name'] == resource[:name]}
  end

  def create
    data = {
      :revision => 0,
      :name     => resource[:name],
      :element  => { :value    => resource[:value].sort.join(','), 
                     :applicationProtocol => resource[:application_protocol],
                   }
    }
    post("api/2.0/services/application/#{@scope_moref}", {:application => data} )
  end

  def destroy
    delete("api/2.0/services/application/#{@application['objectId']}")
  end

  def value
    @application['element']['value']
  end

  [:value=, :application_protocol=].each do |m|
    define_method(m) do |arg|
      # requires us to increment revision number, thing to try in future is omitting revision key
      @application['revision']                       = @application['revision'].to_i + 1
      @application['element']['applicationProtocol'] = resource[:application_protocol]
      @application['element']['value']               = resource[:value]

      # get rid of nil value hash elements
      data                      = {}
      data[:application]        = @application.reject{|k,v| v.nil? }

      Puppet.debug("Updating to #{value}")
      put("api/2.0/services/application/#{@application['objectId']}", data )
    end
  end

  def application_protocol
    @application['element']['applicationProtocol']
  end

end
