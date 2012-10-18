require 'lib/puppet/modules/vcenter'
require 'rbvmomi' unless Puppet.run_mode.master?

module Puppet::Modules
  module Vcenter
    class Puppet::Modules::Vcenter::Transport

      @@instance = []

      attr_accessor :vim
      attr_reader :name
      attr_writer :host, :user, :password

      def initialize(name, username, password, host)
        @name = name
        @user = username
        @password = password
        @host = host
        @vim = RbVmomi::VIM.connect(:host => host, :user => username, :password => password, :insecure => true)
        @@instance << self
      end

      def self.current(name)
        @@instance.find{|x| x.name == name}
      end
    end
  end
end
