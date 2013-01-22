require 'rest_client' if Puppet.features.restclient? and ! Puppet.run_mode.master?

module PuppetX::Puppetlabs::Transport
  class Vshield
    attr_accessor :rest
    attr_reader :name, :user, :password, :host

    def initialize(option)
      @name     = option[:name]
      @user     = option[:username]
      @password = option[:password]
      @host     = option[:server]
      Puppet.debug("#{self.class} initializing connection to: #{@host}")
    end

    def connect
      @rest ||= RestClient::Resource.new("https://#{@host}/", :user => @user, :password => @password, :timeout => 300 )
    end

  end
end
