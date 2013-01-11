require 'puppet/provider/vshield'

Puppet::Type.type(:vshield_application_group).provide(:default, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShield Application Group.'

  def exists?
    results = nested_value(get("/api/2.0/services/applicationgroup/scope/#{vshield_scope_moref}"), ['list', 'applicationGroup'])
    # If there's a single application the result is a hash, while multiple results in an array.
    @application_group = [results].flatten.find {|application_group| application_group['name'] == resource[:name]} if results
  end

  def create
    results = nested_value(get("/api/2.0/services/applicationgroup/scope/#{vshield_scope_moref}"), ['list', 'applicationGroup'])
    Puppet.debug("results = #{results.inspect}")
    raise Puppet::Error, "beginning of create"
    ####
    app_id_members = []
    resource[:application_member].each do |app_member|
      results = nested_value(get("/api/2.0/services/application/scope/#{vshield_scope_moref}"), ['list', 'application'])
      app = [results].flatten.find {|application| application['name'] == app_member}
      # if application does not exist, bomb out
      if app
        app_id_members << { :name     => app_member,
                            :objectId => app['objectId'],
                          }
      else
        raise Puppet::Error, "Application #{app_member} does not exist"
      end
    end
    data = {
      :revision => 0,
      :name     => resource[:name],
      :member   => app_id_members
    }
    post("api/2.0/services/applicationgroup/#{vshield_scope_moref}", {:applicationGroup => data} )
  end

  def destroy
    delete("api/2.0/services/application/#{@application['objectId']}")
  end

  def application_member
    @cur_app_members = []
    if @application_group and @application_group['member']
      # horrible, for only 1 member the type returned from vshield is a hash, otherwise array
      if @application_group['member'].class == Hash
        @application_group['member'] = [ @application_group['member'] ]
      end
      applications     = @application_group['member'].to_a.find_all{ |member| member['objectTypeName'] == 'Application'}
      @cur_app_members = applications.collect{ |member| member['name'] }
    end
    @cur_app_members.sort
  end

  def application_member=(member)
    @pending_changes = true
  end

  def application_group_member
  end

  def application_group_member=(member)
    @pending_changes = true
  end

  def flush
    Puppet.debug("gets here")
    if @pending_changes
      application_group_id = @application_group['objectId']
      resource[:application_member].each do |app_member|
        results = nested_value(get("/api/2.0/services/application/scope/#{vshield_scope_moref}"), ['list', 'application'])
        app     = [results].flatten.find {|application| application['name'] == app_member}
        # if application does not exist, bomb out
        if app
          if @application_group['member']
            if_member = @application_group['member'].find{ |member| member['name'] == app_member }
          end

          if if_member.nil?
            Puppet.debug("Adding #{app_member} to #{resource[:name]}")
            put("api/2.0/services/applicationgroup/#{application_group_id}/members/#{app['objectId']}", '' )
          end
        else
          raise Puppet::Error, "Application #{app_member} does not exist"
        end
      end
      if @application_group['member']
        @application_group['member'].each do |app_member|
          app_name = app_member['name']
          app_id   = app_member['objectId']
          unless resource[:application_member].include?(app_name)
            delete("api/2.0/services/applicationgroup/#{application_group_id}/members/#{app_id}" )
            Puppet.debug("Removing #{app_name} from #{resource[:name]}")
          end
        end
      end 
    end
  end
end
