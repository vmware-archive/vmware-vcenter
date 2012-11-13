require 'puppet/provider/vcenter'

Puppet::Type.type(:esx_syslog).provide(:esx_syslog, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter hosts syslog configuration."

  def initialize(args)
    @prefix       = 'Syslog.global.'
    @changed_value = []

    super(args)
  end

  Puppet::Type.type(:esx_syslog).properties.collect{|x| x.name}.each do |prop|
    camel_prop = prop.to_s.camelize(:lower).to_sym

    define_method(prop) do
      config[camel_prop]
    end

    define_method("#{prop}=") do |value|
      # TODO: rbvmomi automatically cast numbers to long, and we need to query
      # the property and do this manually for RbVmomi::BasicTypes::Int.new.
      # This is pending Ruby 1.8.7 fix.
      @changed_value << { :key => "#{@prefix}#{camel_prop}", :value => value }
    end
  end

  def flush
    begin
      host.configManager.advancedOption.UpdateOptions(:changedValue => @changed_value)
    rescue Exception => e
      raise Puppet::Error, "UpdateOptions failed: #{e.argument}"
    end
  end

  private

  def config
    @config ||= key_value(host.config.option, @prefix)
  end

  def key_value(object, prefix)
    subset = object.select{ |x| x.key=~ /^#{Regexp.escape(prefix)}/ }
    result = Hash[* subset.collect{ |x| [x.key.gsub(/^#{Regexp.escape(prefix)}/,'').to_sym, x.value] }.flatten ]
  end

  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
  end
end
