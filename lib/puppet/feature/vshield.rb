require 'puppet/util/feature'

Puppet.features.rubygems?
Puppet.features.add(:vshield, :libs => %w{gyoku nori})
