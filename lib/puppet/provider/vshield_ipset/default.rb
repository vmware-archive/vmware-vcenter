require 'puppet/provider/vshield'

Puppet::Type.type(:vshield_ipset).provide(:default, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShield ipset.'

  def exists?
    begin
      #all_ipsets = get_detail('ipset') || return false
      all_ipsets = get_detail('ipset') || []
      all_ipsets.each do |list|
        @ipset   = list['list']['ipset'].find{|x| x['name'] == resource[:name]}
        break
      end
    rescue Exception
    end 
    @ipset
  end

  def create
    Puppet.debug("create ipset #{resource[:name]}")
    data = {}
    data[:name]     = resource[:name]
    data[:value]    = resource[:value].sort.join(',')
    Puppet.debug("data[:value] = #{data[:value]}")
    #data[:value]    = resource[:value]
    data[:revision] = '0'
    post("api/2.0/services/ipset/#{@scope_moref}", { :ipset => data } )
  end

  def destroy
    # not implemented
  end

  def ip_value
    Puppet.debug("@ipset[:value] = #{@ipset[:value].split(',').sort}")
    @ipset['value'].split(',').sort
  end

  def ip_value=(ips)
    Puppet.debug("value = #{@resource[:ip_value].inspect}")
    Puppet.debug("@ipset[:value] = #{resource[:ip_value].sort.join(',')}")
    data               = {}
    # requires us to increment revision number, thing to try in future is omitting revision key
    @ipset['revision'] = @ipset['revision'].to_i + 1
    @ipset['value']    = resource[:ip_value].sort.join(',')
    # get rid of nil value hash elements
    data[:ipset]       = @ipset.reject{|k,v| v.nil? }
    
    Puppet.debug("Updating to #{ips}")
    put("api/2.0/services/ipset/#{@ipset['objectId']}", data )
  end

end
