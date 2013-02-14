# Copyright (C) 2013 VMware, Inc.
# vCenter common parameters
class vcenter::params {

  if $::puppetversion =~ /Puppet Enterprise/ {
    $provider  = 'pe_gem'
    $ruby_path = '/opt/puppet/bin/ruby'
  } else {
    $provider  = 'gem'
    $ruby_path = '/usr/bin/env ruby'
  }

}
