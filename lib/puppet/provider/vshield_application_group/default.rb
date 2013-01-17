require 'puppet/provider/vshield'

Puppet::Type.type(:vshield_application_group).provide(:default, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShield Application Group.'

  def exists?
    results = ensure_array( nested_value(get("/api/2.0/services/applicationgroup/scope/#{vshield_scope_moref}"), ['list', 'applicationGroup']) )
    # If there's a single application the result is a hash, while multiple results in an array.
    @app_group = results.find{|application_group| application_group['name'] == resource[:name]}
    Puppet.debug("@app_group = #{@app_group.inspect}")
    populate_member
    @app_group
  end

  def populate_member
    if @app_group
      @app_group['member'] = ensure_array(@app_group['member'])
      @app_group['application_member'] = ensure_array(@app_group['application_member'])
      @app_group['application_group_member'] = ensure_array(@app_group['application_group_member'])
    end
  end

  def create
    # Create blank application ( service ) group and use @pending_changes in flush to
    # poplulate application and application_group members
    data = {
      :revision => 0,
      :name     => resource[:name],
    }
    post("api/2.0/services/applicationgroup/#{vshield_scope_moref}", {:applicationGroup => data} )

    @pending_changes = true
    results = ensure_array( nested_value(get("/api/2.0/services/applicationgroup/scope/#{vshield_scope_moref}"), ['list', 'applicationGroup']) )

    # If there's a single application the result is a hash, while multiple results in an array.
    @app_group = results.find {|application_group| application_group['name'] == resource[:name]}
    populate_member
  end

  def destroy
    delete("api/2.0/services/application/#{@application['objectId']}")
  end

  def application_member
    cur_app_members = []
    applications    = @app_group['member'].to_a.find_all{ |member| member['objectTypeName'] == 'Application'}
    cur_app_members = applications.collect{ |member| member['name'] }
    cur_app_members.sort
  end

  def application_member=(member)
    @pending_changes = true
  end

  def application_group_member
    cur_app_members = []
    applications    = @app_group['member'].to_a.find_all{ |member| member['objectTypeName'] == 'ApplicationGroup'}
    cur_app_members = applications.collect{ |member| member['name'] }
    cur_app_members.sort
  end

  def application_group_member=(member)
    @pending_changes = true
  end

  def flush
    if @pending_changes
      raise Puppet::Error, "Application Group #{resource[:name]} was not found" unless @app_group
      application_group_id = @app_group['objectId']
      # for all application_members add ones not currently members
      if resource[:application_member]
        resource[:application_member].each do |app_member|
          results = ensure_array( nested_value(get("/api/2.0/services/application/scope/#{vshield_scope_moref}"), ['list', 'application']) )
          app     = results.find {|application| application['name'] == app_member}
          raise Puppet::Error, "Application #{app_member} does not exist, it will not be added to #{resource[:name]}" if app.nil?

          # if application does not exist, bomb out
          existing_member = ensure_array( @app_group['member']).find{ |member| member['name'] == app_member and member['objectTypeName'] == 'Application' }

          if existing_member.nil?
            Puppet.debug("Adding #{app_member} to #{resource[:name]}")
            put("api/2.0/services/applicationgroup/#{application_group_id}/members/#{app['objectId']}", {} )
          end
        end
        # for all current application_members remove ones not in resource[:application_members]
        @app_group['member'] ||= []
        @app_group['member'].each do |app_member|
          app_name = app_member['name']
          app_id   = app_member['objectId']
          unless resource[:application_member].include?(app_name)
            Puppet.debug("Removing #{app_name} from #{resource[:name]}")
            delete("api/2.0/services/applicationgroup/#{application_group_id}/members/#{app_id}" )
          end
        end
      end

      # add all application_groups that are not currently members
      if resource[:application_group_member]
        resource[:application_group_member].each do |app_member|
          results = ensure_array( nested_value(get("/api/2.0/services/applicationgroup/scope/#{vshield_scope_moref}"), ['list', 'applicationGroup']) )
          app     = results.find {|app_group| app_group['name'] == app_member and app_group['objectTypeName'] == 'ApplicationGroup' }
          # if application does not exist, error out and dont update
          raise Puppet::Error, "ApplicationGroup #{app_member} does not exist, it will not be added to #{resource[:name]}" if app.nil?
          existing_member = @app_group['member'].find{ |member| member['name'] == app_member }

          if existing_member.nil?
            Puppet.debug("Adding #{app_member} to #{resource[:name]}")
            put("api/2.0/services/applicationgroup/#{application_group_id}/members/#{app['objectId']}", {} )
          end
        end
        # for all current application_members remove ones not in resource[:application_members]
        @app_group['member'].each do |app_member|
          app_name = app_member['name']
          app_id   = app_member['objectId']
          unless resource[:application_group_member].include?(app_name)
            Puppet.debug("Removing #{app_name} from #{resource[:name]}")
            delete("api/2.0/services/applicationgroup/#{application_group_id}/members/#{app_id}" )
          end
        end
      end
    end
  end
end
