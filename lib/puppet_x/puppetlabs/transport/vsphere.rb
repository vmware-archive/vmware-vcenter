require 'rbvmomi' if Puppet.features.vsphere? and ! Puppet.run_mode.master?

module PuppetX::Puppetlabs::Transport
  class Vsphere
    attr_accessor :vim
    attr_reader :name, :user, :password, :host

    def initialize(option)
      @name     = option[:name]
      @user     = option[:username]
      @password = option[:password]
      @host     = option[:server]
      Puppet.debug("#{self.class} initializing connection to: #{@host}")
    end

    def connect
      @vim ||= RbVmomi::VIM.connect(:host => @host, :user => @user, :password => @password, :insecure => true)
    end

    def close
      @vim.close if @vim
    end
  end
end
