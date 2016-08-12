Puppet::Type.newtype(:esx_firewall_ruleset) do
  @doc = <<-EOT
  This type manages ESX firewall rulesets on a host.  This title has two namevars
  host and name, the name may be specified in the title, or both the name and the
  host delimited with a comma, eg;


  esx_firewall_ruleset { 'ntp rule':
    ensure    => enabled,
    name      => 'ntpClient',
    host      => 'esxi1.localdomain',
    transport => Transport['vcenter'],
  }

  esx_firewall_ruleset { 'ntpClient':
    ensure    => enabled,
    host      => 'esxi1.localdomain',
    transport => Transport['vcenter'],
  }

  esx_firewall_ruleset { 'esxi1.localdomain:ntpClient':
    ensure    => enabled,
    transport => Transport['vcenter'],
  }

  EOT

  def self.title_patterns
    identity = lambda { |x| x }
    [ 
      [ 
        /^([^:]+):([^:]+)$/,
        [ [:host, identity], [:name, identity] ]
      ],
      [
        /^([^:]+)$/,
        [[ :name, identity ]]
      ]
    ]
  end

  validate do
    raise ArgumentError, "Must supply path" unless self[:path]
    raise ArgumentError, "Must supply host in title or host attribute" unless self[:host]
  end

  ensurable do
    desc <<-EOT
    Valid ensure values are "enabled" and "disabled" (present and absent will also
    map to their respective values)
    EOT
    newvalue(:enabled) do
      provider.enable
    end
    newvalue(:disabled) do
      provider.disable
    end

    aliasvalue :absent, :disabled
    aliasvalue :present, :enabled
    defaultto(:enabled)

    def retrieve
      provider.enabled? ? :enabled : :disabled
    end
  end

  newparam(:path) do
    desc "Datacenter path where host resides"
    validate do |path|
      raise ArgumentError, "Absolute path is required: #{path}" unless Puppet::Util.absolute_path?(path)
    end
  end

  newparam(:name) do
    desc "The name of the firewall rulset, eg: ntpClient"
    isnamevar
  end

  newparam(:host) do
    isnamevar
    desc "ESX host to configure"
  end

  newproperty(:allowed_hosts, :array_matching => :all) do
    desc <<-EOT
      A list of allowed IP ranges

      This attribute can take a single string value of "all" indicating that
      all IP addresses are allowed for this ruleset, alternatively an array
      of IP addresses, or IP address ranges with prefixes may be given.

      Allow all hosts
      allowed_hosts => 'all'

      Allow multiple hosts
      allowed_hosts => [
        '192.168.10.2',
        '192.168.200.0/24',
        '10.72.99.0/24'
      ]
    EOT
    validate do |value|
      unless ( value =~ /^\d+\.\d+\.\d+.\d+(\/\d+|)$/ || value == 'all' )
        raise Puppet::Error, "malformed IP address or network #{value}"
      end
    end

    def insync?(is)
      Array(is).sort == Array(should).sort
    end
  end
end
