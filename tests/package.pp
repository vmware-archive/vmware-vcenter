# RHEL 6 package dependency for nokogiri gem (for non-PE environment):
package {
  [ 'ruby-devel',
    'libxml2',
    'libxml2-devel',
    'libxslt',
    'libxslt-devel'
  ]:
    ensure => present,
} ->

class { 'vcenter::package': }
