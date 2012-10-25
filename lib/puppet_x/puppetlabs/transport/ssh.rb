require 'net/ssh' unless Puppet.run_mode.master?

module Puppet_X::Puppetlabs::Transport
  class Ssh
    attr_accessor :ssh
    attr_reader :name, :user, :password, :host

    def initialize(option)
      @name     = option[:name]
      @user     = option[:username]
      @password = option[:password]
      @host     = option[:server]
      Puppet.debug("#{self.class} initializing connection to: #{@host}")
    end

    def connect
      @ssh ||= Net::SSH.start(@host, @user, :password => @password, :timeout => 10)
    end

    # wrapper for debugging
    def exec!(command)
      Puppet.debug("Executing on #{@host}:\n#{command}")
      result = @ssh.exec!(command)
      Puppet.debug("Execution result:\n#{@result}")
      result
    end

    def exec(command)
      Puppet.debug("Executing on #{@host}:\n#{command}")
      @ssh.exec(command)
    end

    def close
      @ssh.close if @ssh
    end
  end
end
