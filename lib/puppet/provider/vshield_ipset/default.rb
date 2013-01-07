require 'puppet/provider/vshield'

Puppet::Type.type(:vshield_ipset).provide(:default, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShield ipset.'

  def ret_datacenter_id(name=resource[:datacenter_name])
    dc = vim.serviceInstance.find_datacenter(name) or raise Puppet::Error, "datacenter '#{name}' not found."
    dc._ref
  end

  def exists?
    begin
      all_ipsets = ipset_detail || []
      all_ipsets.each do |list|
        #Puppet.debug("list = #{list['list']['ipset'].inspect}")
        #Puppet.debug("class = #{list['list']['ipset'].class}")
        @ipset   = list['list']['ipset'].find{|x| x['name'] == resource[:name]} 
        Puppet.debug("@ipset = #{@ipset.inspect}")
        break
      end
    rescue Exception
    end 
    Puppet.debug("@ipset = #{@ipset.inspect}")
    #raise Puppet::Error, "end exists"
    @ipset
  end

  def create
    Puppet.debug("@ipset = #{@ipset.inspect}")
    Puppet.debug("create ipset #{resource[:name]}")
    data = {}
    data[:name]     = "#{resource[:name]}"
    data[:value]    = "#{resource[:value]}" 
    data[:revision] = '0'
    Puppet.debug("data = #{data.inspect}")
    post("api/2.0/services/ipset/#{@scope_moref}", { :ipset => data } )
  end

  def destroy
    # not implemented
  end

  def value
    Puppet.debug("@ipset['value'] = #{@ipset['value']}")
    @ipset['value']
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

  def ipset_detail
    @scope_moref = ''
    if resource[:scope_type].to_s == 'datacenter'
      @scope_moref = ret_datacenter_id(resource[:scope_name])
      Puppet.debug("datacenter_id = #{datacenter_id.inspect}")
    else
      result = edge_summary || []
      instance = result.find{|x| x['name'] == resource[:scope_name]}
      #Puppet.debug("instance = #{instance['id'].inspect}")
      @scope_moref = instance['id']
    end
    get_all_ipsets("/api/2.0/services/ipset/scope/#{@scope_moref}")
  end
end
