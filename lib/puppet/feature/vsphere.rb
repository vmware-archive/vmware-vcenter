require 'puppet/util/feature'

Puppet.features.rubygems?
Puppet.features.add(:vsphere, :libs => %w{rbvmomi})
