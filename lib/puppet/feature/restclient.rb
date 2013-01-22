require 'puppet/util/feature'

Puppet.features.rubygems?
Puppet.features.add(:restclient, :libs => %w{rest_client})
