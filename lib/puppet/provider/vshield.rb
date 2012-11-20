require 'pathname'
require 'puppet_x/puppetlabs/transport'
require 'puppet_x/puppetlabs/transport/vshield'
require 'puppet_x/vmware/util'

unless Puppet.run_mode.master?
  # Using Savon's library:
  require 'nori'
  require 'gyoku'
end

class Puppet::Provider::Vshield <  Puppet::Provider

  private

  def rest
    @transport ||= PuppetX::Puppetlabs::Transport.retrieve(resource[:transport], resource.catalog, 'vshield')
    @transport.rest
  end

  [:get, :delete].each do |m|
    define_method(m) do |url|
      result = Nori.parse(rest[url].send(m))
      Puppet.debug "VShield REST API #{m} #{url} result:\n#{result.inspect}"
      result
    end
  end

  [:put, :post].each do |m|
    define_method(m) do |url, data|
      result = rest[url].send(m, Gyoku.xml(data), :content_type => 'application/xml; charset=UTF-8')
      Puppet.debug "VShield REST API #{m} #{url} with #{data.inspect} result:\n#{result.inspect}"
    end
  end
end
