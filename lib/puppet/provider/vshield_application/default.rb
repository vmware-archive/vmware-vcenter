require 'puppet/provider/vshield'

Puppet::Type.type(:vshield_application).provide(:default, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShield application.'

  def exists?
    results = ensure_array( nested_value(get("/api/2.0/services/application/scope/#{vshield_scope_moref}"), ['list', 'application']) )
    # If there's a single application the result is a hash, while multiple results in an array.
    @application = results.find {|application| application['name'] == resource[:name]}
  end

  def create
    data = {
      :revision => 0,
      :name     => resource[:name],
      :element  => { :value    => resource[:value].sort.join(','), 
                     :applicationProtocol => resource[:application_protocol],
                   }
    }
    post("api/2.0/services/application/#{vshield_scope_moref}", {:application => data} )
  end

  def destroy
    delete("api/2.0/services/application/#{@application['objectId']}")
  end

  def value
    @application['element']['value']
  end

  def value=(ports)
    @pending_changes = true
  end

  def application_protocol
    @application['element']['applicationProtocol']
  end

  def application_protocol=(proto)
    @pending_changes = true
  end

  def flush
    if @pending_changes
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

end
