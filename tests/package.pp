# Copyright (C) 2013 VMware, Inc.
# RHEL 6 package dependency for nokogiri gem:
package { ['ruby-devel', 'libxml2', 'libxml2-devel', 'libxslt', 'libxslt-devel']:
  ensure => present,
}

include 'vcenter::package'
