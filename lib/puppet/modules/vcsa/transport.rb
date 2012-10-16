require 'lib/puppet/modules/vcsa'
require 'net/ssh'

module Puppet::Modules
  module Vcsa
    class Puppet::Modules::Vcsa::Transport

      @@instance = []

      attr_accessor :channel, :buf
      attr_reader :name
      attr_writer :host, :user, :password

      def initialize(name, username, password, host)
        @name = name
        @user = username
        @password = password
        @host = host
        @ssh = Net::SSH.start(@host, @user, :password => @password, :timeout => 10)
        @@instance << self
      end

      def send(command)
        Puppet.debug("Executing on #{@host}:\n#{command}")
        @result = @ssh.exec!(command)
        Puppet.debug("Execution result:\n#{@result}")
      end

      def result
        @result
      end

      def self.current(name)
        @@instance.find{|x| x.name == name}
      end
    end
  end
end
