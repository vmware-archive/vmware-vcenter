require 'puppet/provider/vshield'

Puppet::Type.type(:vshield_ipset).provide(:default, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShield ipset.'

  def exists?
    begin
      all_ipsets = ipset_detail || return false
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
    @ipset
  end

  def create
    Puppet.debug("@ipset = #{@ipset.inspect}")
    Puppet.debug("create ipset #{resource[:name]}")
    data = {}
    data[:name]     = resource[:name]
    data[:value]    = resource[:value]
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

end
