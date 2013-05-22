# Copyright (C) 2013 VMware, Inc.
class vcenter::package (
) inherits vcenter::params {

  package { [
    'hashdiff',
    'rest-client',
    'net-ssh',
  ]:
    ensure   => present,
    provider => $::vcenter::params::provider,
  }

  # nori 2.0.0 gem is not compatible with PE (nokogiri?)
  package { 'nori':
    ensure   => '1.1.4',
    provider => $::vcenter::params::provider,
  }

  # custom gyoku to support array of attributes with no value:
  #   <refs>
  #     <ref name="1" />
  #     <ref name="2" />
  #   </refs>

  staging::file { 'gyoku.gem':
    source => 'puppet:///modules/vcenter/gyoku-1.0.0.z2.gem',
  } ->

  package { 'gyoku':
    ensure   => '1.0.0z2',
    source   => '/opt/staging/vcenter/gyoku.gem',
    provider => $::vcenter::params::provider,
  }

  staging::file { 'rbvmomi.gem':
    source => 'puppet:///modules/vcenter/rbvmomi-1.6.0.z1.gem',
  } ->

  package { 'rbvmomi':
    ensure   => '1.6.0.z1',
    source   => '/opt/staging/vcenter/rbvmomi.gem',
    provider => $::vcenter::params::provider,
  }
}
