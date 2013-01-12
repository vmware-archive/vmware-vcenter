require 'puppet/provider/vshield'

Puppet::Type.type(:vshield_application_group).provide(:default, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShield Application Group.'

  def exists?
    results = nested_value(get("/api/2.0/services/applicationgroup/scope/#{vshield_scope_moref}"), ['list', 'applicationGroup'])
    # If there's a single application the result is a hash, while multiple results in an array.
    @application_group = [results].flatten.find {|application_group| application_group['name'] == resource[:name]} if results
  end

  def create
    # Create blank application ( service ) group and use @pending_changes in flush to
    # poplulate application and application_group members
    data = {
      :revision => 0,
      :name     => resource[:name],
      #:member   => app_id_members
    }

    @pending_changes = true
    results = nested_value(get("/api/2.0/services/applicationgroup/scope/#{vshield_scope_moref}"), ['list', 'applicationGroup'])

    # If there's a single application the result is a hash, while multiple results in an array.
    @application_group = [results].flatten.find {|application_group| application_group['name'] == resource[:name]} if results

    post("api/2.0/services/applicationgroup/#{vshield_scope_moref}", {:applicationGroup => data} )
  end

  def destroy
    delete("api/2.0/services/application/#{@application['objectId']}")
  end

  def application_member
    cur_app_members = []
    if @application_group and @application_group['member']
      # horrible, for only 1 member the type returned from vshield is a hash, otherwise array
      if @application_group['member'].class == Hash
        @application_group['member'] = [ @application_group['member'] ]
      end
      applications    = @application_group['member'].to_a.find_all{ |member| member['objectTypeName'] == 'Application'}
      cur_app_members = applications.collect{ |member| member['name'] }
    end
    cur_app_members.sort
  end

  def application_member=(member)
    @pending_changes = true
  end

  def application_group_member
    cur_app_members = []
    if @application_group and @application_group['member']
      # horrible, for only 1 member the type returned from vshield is a hash, otherwise array
      if @application_group['member'].class == Hash
        @application_group['member'] = [ @application_group['member'] ]
      end
      applications    = @application_group['member'].to_a.find_all{ |member| member['objectTypeName'] == 'ApplicationGroup'}
      cur_app_members = applications.collect{ |member| member['name'] }
    end
    cur_app_members.sort
  end

  def application_group_member=(member)
    @pending_changes = true
  end

  def flush
    raise Puppet::Error, "Application Group #{resource[:name]} was not found" unless @application_group
    if @pending_changes
      application_group_id = @application_group['objectId']
      # for all application_members add ones not currently members
      if resource[:application_member]
        resource[:application_member].each do |app_member|
          results = nested_value(get("/api/2.0/services/application/scope/#{vshield_scope_moref}"), ['list', 'application'])
          app     = [results].flatten.find {|application| application['name'] == app_member}
          # if application does not exist, bomb out
          if app
            if @application_group['member']
              if_member = @application_group['member'].find{ |member| member['name'] == app_member and member['objectTypeName'] == 'Application' }
            end

            if if_member.nil?
              Puppet.debug("Adding #{app_member} to #{resource[:name]}")
              put("api/2.0/services/applicationgroup/#{application_group_id}/members/#{app['objectId']}", {} )
            end
          else
            Puppet.warning "Application #{app_member} does not exist, it will not be added to #{resource[:name]}"
          end
        end
        # for all current application_members remove ones not listed in the resource[:application_members]
        if @application_group['member']
          @application_group['member'].each do |app_member|
            app_name = app_member['name']
            app_id   = app_member['objectId']
            unless resource[:application_member].include?(app_name)
              Puppet.debug("Removing #{app_name} from #{resource[:name]}")
              delete("api/2.0/services/applicationgroup/#{application_group_id}/members/#{app_id}" )
            end
          end
        end 
      end

      # add all application_groups that are not currently members
      if resource[:application_group_member]
        resource[:application_group_member].each do |app_member|
          results = nested_value(get("/api/2.0/services/applicationgroup/scope/#{vshield_scope_moref}"), ['list', 'applicationGroup'])
          app     = [results].flatten.find {|app_group| app_group['name'] == app_member and app_group['objectTypeName'] == 'ApplicationGroup' }
          # if application does not exist, give warning and don't update
          if app
            if @application_group['member']
              if_member = @application_group['member'].find{ |member| member['name'] == app_member }
            end

            if if_member.nil?
              Puppet.debug("Adding #{app_member} to #{resource[:name]}")
              put("api/2.0/services/applicationgroup/#{application_group_id}/members/#{app['objectId']}", {} )
            end
          else
            Puppet.warning "ApplicationGroup #{app_member} does not exist, it will not be added to #{resource[:name]}"
          end
        end
        # for all current application_members remove ones not listed in the resource[:application_members]
        if @application_group['member']
          @application_group['member'].each do |app_member|
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
end
