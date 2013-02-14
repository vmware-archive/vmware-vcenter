require 'rbvmomi' if Puppet.features.vsphere? and ! Puppet.run_mode.master?

module PuppetX::Puppetlabs::Transport
  class Vsphere
    attr_accessor :vim
    attr_reader :name, :user, :password, :host

    def initialize(opts)
      options  = opts[:options] || {}
      @options = options.inject({}){|h, (k, v)| h[k.to_sym] = v; h}
      @options[:host]     = opts[:server]
      @options[:user]     = opts[:username]
      @options[:password] = opts[:password]
      Puppet.debug("#{self.class} initializing connection to: #{@host}")
    end

    def connect
      @vim ||= RbVmomi::VIM.connect(@options)
    end

    def close
      @vim.close if @vim
    end
  end
end
