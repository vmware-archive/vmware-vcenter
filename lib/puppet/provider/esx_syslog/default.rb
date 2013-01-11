require 'puppet/provider/vcenter'

Puppet::Type.type(:esx_syslog).provide(:esx_syslog, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter hosts syslog configuration."

  def initialize(args)
    @prefix       = 'Syslog.global.'
    @changed_value = []

    super(args)
  end

  Puppet::Type.type(:esx_syslog).properties.collect{|x| x.name}.each do |prop|
    camel_prop = PuppetX::VMware::Util.camelize(prop, :lower).to_sym

    define_method(prop) do
      v = config[camel_prop]
      v = :false if FalseClass === v
      v = :true  if TrueClass  === v
      v
    end

    define_method("#{prop}=") do |value|
      # TODO: rbvmomi automatically cast numbers to long, and we need to query
      # the property and do this manually for RbVmomi::BasicTypes::Int.new.
      # This is pending Ruby 1.8.7 fix.
      if [ :default_rotate, :default_size ].include? prop
        value = RbVmomi::BasicTypes::Int.new value
      elsif prop == :log_dir_unique
        value = (value == :true)
      end
      @changed_value << { :key => "#{@prefix}#{camel_prop}", :value => value }
    end
  end

  def flush
    begin
      unless @changed_value.empty?
        host.configManager.advancedOption.UpdateOptions(:changedValue => @changed_value)
      end
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
