provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:esx_firewall_ruleset).provide(
  :default, 
  :parent => Puppet::Provider::Vcenter
) do


  @doc = "Manages ESXi firewall rulesets"

  def enable
    firewall_config.EnableRuleset(:id => @resource[:name])
  end

  def disable
    firewall_config.DisableRuleset(:id => @resource[:name])
  end

  #Check for existence of vSwitch
  def enabled?
    ruleset(resource[:name]).enabled
  end

  def allowed_hosts
    hosts = ruleset(resource[:name]).allowedHosts
    return "all" if hosts.allIp
    ips = []
    ips << hosts.ipAddress
    hosts.ipNetwork.each do |cidr|
      ips << "#{cidr.network}/#{cidr.prefixLength}"
    end
    ips.flatten
  end

  def allowed_hosts=(should)
    all_ip=nil
    networks=[]
    ipaddresses=[]

    if should == [ 'all' ]
      all_ip=true
    else
      all_ip=false
      should.each do |ip|
        address, prefix = ip.split(/\//)
        if prefix.nil?
          ipaddresses << address
        else
          networks << {
            :network => address,
            :prefixLength => prefix
          }
        end
      end
    end

    firewall_config.UpdateRuleset(
      :id => @resource[:name],
      :spec => {
        :allowedHosts => {
          :allIp => all_ip,
          :ipAddress => ipaddresses,
          :ipNetwork => networks
        }
      }
    )
  end



  def ruleset(name)
    set = firewall_config.firewallInfo.ruleset.select { |r| 
      r.key == name 
    }
    raise Puppet::Error, "No firewall ruleset named #{name}" if set.empty?
    set[0]
  end



  def firewall_config
    @firewall_config ||= esx_host.configManager.firewallSystem
    @firewall_config
  end

  # TODO: centralize this for all esx providers!

  def walk_dc(path=resource[:path])
    datacenter = walk(path, RbVmomi::VIM::Datacenter)
    raise Puppet::Error.new( "No datacenter in path: #{path}") unless datacenter
    datacenter
  end

  def esx_host
    @esx_host ||= vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
    raise Puppet::Error.new("An invalid host name or IP address is entered. Enter the correct host name and IP address.") unless @esx_host
    @esx_host
  end
end
