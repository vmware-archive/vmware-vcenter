require 'lib/puppet/provider/vcenter'

Puppet::Type.type(:esx_shells).provide(:esx_shells, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter hosts' ESXi Shell and SSH configuration."

  def initialize(args)
    @prefix       = 'UserVars.'
    @changed_value = []

    # TODO: we lose camelcase when properties are created.
    @propmap = {
      :esxi_shell_time_out            => 'ESXiShellTimeOut',
      :esxi_shell_interactive_time_out => 'ESXiShellInteractiveTimeOut',
      :suppress_shell_warning        => 'SuppressShellWarning',
    }
    @propmap.each_pair do |k, v| @propmap[k] = (@prefix + v).to_sym end

    super(args)
  end


  Puppet::Type.type(:esx_shells).properties.collect{|x| x.name}.each do |prop|
    define_method(prop) do
      key = @propmap[prop] || prop
      if config.include? key
        value = config[key]
      else
        Puppet.debug "ESX shells #{resource[:name]} -- get failed for " +
            "property/key '#{prop}'/'#{key}' in object '#{config.inspect}'"
        fail "property '#{prop}' not found in map"
      end
    end

    define_method("#{prop}=") do |value|
      Puppet.debug "ESX shells #{resource[:name]} -- set " +
          "property/key '#{prop}'/'#{@propmap[prop]}' " +
          "to '#{value.inspect}'"
      # TODO: rbvmomi automatically cast numbers to long, and we need to query
      # the property and do this manually for RbVmomi::BasicTypes::Int.new.
      # This is pending Ruby 1.8.7 fix.
      @changed_value << { :key => "#{@propmap[prop] || prop}", :value => value }
    end
  end

  def flush
    unless @changed_value.empty?
      begin
        host.configManager.advancedOption.UpdateOptions(:changedValue => @changed_value)
      rescue Exception => e
        raise Puppet::Error, "UpdateOptions failed: #{e.argument}"
      end
    end
  end

  private

  def config
    @config ||= key_value(host.config.option, @prefix)
  end

  def key_value(object, prefix)
    subset = object.select{ |x| x.key=~ /^#{Regexp.escape(prefix)}/ }
    result = Hash[* subset.collect{ |x| [x.key.to_sym, x.value] }.flatten ]
  end

  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
  end
end

