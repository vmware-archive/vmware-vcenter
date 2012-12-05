require 'puppet/provider/vshield'

Puppet::Type.type(:vshield_edge).provide(:vshield_edge, :parent => Puppet::Provider::Vshield) do
  @doc = 'Manages vShield edge.'

  { :enable_aesni => 'aesni?enable=',
    :enable_fips  => 'fips?enable=',
    :enable_tcp_loose => 'tcploose?enable=',
    :vse_log_level => 'logging?level='
  }.each do |property, request|
    camel_prop = PuppetX::VMware::Util.camelize(property, :lower).to_sym
    request ||= property.to_s.sub(/^enable_/,'').sub(/_/, '') + '?enable='

    define_method(property) do
      value = edge_detail[camel_prop.to_s]
      if (value.is_a? TrueClass) || (value.is_a? FalseClass)
        value ? :true : :false
      else
        value
      end
    end

    define_method("#{property}=".to_sym) do |value|
      post("api/3.0/edges/#{@instance['id']}/#{request}#{value}", {})
    end
  end

  def firewall
    get("api/3.0/edges/#{@instance['id']}/firewall/config")['firewall']
  end

  def firewall=(value)
    put("api/3.0/edges/#{@instance['id']}/firewall/config", {:firewall => value})
  end

  def exists?
    result = edge_summary || []
    begin
      @instance = result.find{|x| x['name'] == resource[:edge_name]}
    rescue Exception
    end
  end

  def create
    appliance = {
      :resourcePoolId => compute.resourcePool._ref,
      :datastoreId => datastore._ref,
    }

    data = {
      :datacenterMoid => datacenter._ref,
      :name => resource[:edge_name],
      :description => 'VShield Edge managed by Puppet',
      # TODO: not sure if we ever get more than one:
      :appliances => {
        :applianceSize => resource[:appliance_size],
        :appliance => appliance.merge(resource[:appliance] || {}),
      },
    }

    if resource[:vnics]
      vnics = []
      resource[:vnics].each_with_index do |v, i|
        nic_defaults = {
          :index => i
        }
        vnics << nic_defaults.merge(v)
      end
      data[:vnics] = vnics
    end

    order =  [:datacenterMoid, :name, :description, :tenant, :fqdn, :vseLogLevel, :enableAesni, :enableFips, :enableTcpLoose, :appliances]
    data[:order!] = order - (order - data.keys)

    post("api/3.0/edges",:edge => data)
  end

  def destroy
    delete("api/3.0/edges/#{@instance['id']}")
  end

  private

  def datacenter(name=resource[:datacenter_name])
    vim.serviceInstance.find_datacenter name or raise Puppet::Error, "datacenter '#{name}' not found."
  end

  def compute(name=resource[:compute])
    datacenter.find_compute_resource name or raise Puppet::Error, "compute resource '#{name}' not found."
  end

  def datastore
    if resource[:datastore]
      datacenter.find_datastore resource[:datastore]
    else
      compute.datastore.first
    end
  end

  def edge_summary
    # TODO: This may exceed 256 pagesize limit.
    @edge_summary ||= [get('api/3.0/edges')['pagedEdgeList']['edgePage']['edgeSummary']].flatten
  end

  def edge_detail
    raise Puppet::Error, "edge not available" unless @instance
    @edge_detail ||= get("api/3.0/edges/#{@instance['id']}")['edge']
  end
end

