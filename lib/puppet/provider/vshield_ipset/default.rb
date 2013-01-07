require 'puppet/provider/vshield'

Puppet::Type.type(:vshield_ipset).provide(:default, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShield ipset.'

  def ret_datacenter_id(name=resource[:datacenter_name])
    dc = vim.serviceInstance.find_datacenter(name) or raise Puppet::Error, "datacenter '#{name}' not found."
    dc._ref
  end

  def exists?
    true
  end

  def destroy
    # not implemented
  end

  def value
    value = ''
    @scope_moref = ''
    # not implemented
    if resource[:scope_type].to_s == 'datacenter'
      @scope_moref = ret_datacenter_id(resource[:scope_name])
      Puppet.debug("datacenter_id = #{datacenter_id.inspect}")
    else
      result = edge_summary || []
      instance = result.find{|x| x['name'] == resource[:scope_name]}
      #Puppet.debug("instance = #{instance['id'].inspect}")
      @scope_moref = instance['id']
    end
    if @scope_moref != ''
      all_ipsets = get_all_ipsets("/api/2.0/services/ipset/scope/#{@scope_moref}")
      all_ipsets.each do |list|
        #Puppet.debug("list = #{list['list']['ipset'].inspect}")
        #Puppet.debug("class = #{list['list']['ipset'].class}")
        @ipset   = list['list']['ipset'].find{|x| x['name'] == resource[:name]} 
        Puppet.debug("@ipset = #{@ipset.inspect}")
        ipset_id = @ipset['objectId']
        value    = @ipset['value']
        break
      end
    end
    Puppet.debug("value = #{value}")
    value
  end

  def value=(value)
    data               = {}
    # requires us to increment revision number, thing to try in future is omitting revision key
    @ipset['revision'] = @ipset['revision'].to_i + 1
    @ipset['value']    = resource[:value]
    # get rid of nil value hash elements
    data[:ipset]       = @ipset.reject{|k,v| v.nil? }
    
    Puppet.debug("ipset =  #{@ipset.inspect}")
    Puppet.debug("data  =  #{data.inspect}")
    Puppet.debug("scope_moref =  #{@scope_moref}")
    Puppet.debug("Updating to #{value}")
    put("api/2.0/services/ipset/#{@ipset['objectId']}", data )
    raise Puppet::Error, "end value= def"
  end

  def edge_summary
    # TODO: This may exceed 256 pagesize limit.
    @edge_summary ||= [get('api/3.0/edges')['pagedEdgeList']['edgePage']['edgeSummary']].flatten
  end

  def get_all_ipsets(url)
    all_ipsets ||= [get(url)].flatten
  end

  def edge_detail
    raise Puppet::Error, "edge not available" unless @instance
    Puppet.debug "@instance = #{@instance}"
    @edge_detail ||= get("api/3.0/edges/#{@instance['id']}")['edge']
  end  

end
