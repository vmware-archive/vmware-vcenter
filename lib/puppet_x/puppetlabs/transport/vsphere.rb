# Copyright (C) 2013 VMware, Inc.
if Puppet.features.vsphere? and ! Puppet.run_mode.master?
  require 'rbvmomi'
  require_relative 'rbvmomi_patch' # Use patched library to workaround rbvmomi issues
end

module PuppetX::Puppetlabs::Transport
  class Vsphere
    attr_accessor :vim
    attr_reader :name

    def initialize(opts)
      @name    = opts[:name]
      options  = opts[:options] || {}
      @options = options.inject({}){|h, (k, v)| h[k.to_sym] = v; h}
      @options[:host]     = opts[:server]
      @options[:user]     = opts[:username]
      @options[:password] = opts[:password]
      Puppet.debug("#{self.class} initializing connection to: #{@options[:host]}")
    end

    def connect
      @vim ||= begin
        Puppet.debug("#{self.class} opening connection to #{@options[:host]}")
        RbVmomi::VIM.connect(@options)
      rescue Exception => e
        Puppet.warning("#{self.class} connection to #{@options[:host]} failed; retrying once...")
        RbVmomi::VIM.connect(@options)
      end
    end

    def close
      Puppet.debug("#{self.class} closing connection to: #{@options[:host]}")
      @vim.close if @vim
    end

    def reconnect
      close
      reconnect_opts = {
          :host => @options[:host], :port => @options[:port], :user => @options[:user], :password => @options[:password],
          :insecure => @options[:insecure] || true
      }
      Puppet.debug("Reconnecting to %s" % reconnect_opts[:host])
      @vim = RbVmomi::VIM.connect(reconnect_opts)
    end
  end
end
