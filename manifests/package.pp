# Copyright (C) 2013 VMware, Inc.
class vcenter::package (
  $provider = $vcenter::params::provider,
) inherits vcenter::params {

  package { [
    'rest-client',
  ]:
    ensure   => present,
    provider => $provider,
  }

  # net-ssh gem 2.1.4 (PE3) is incompatible with vcsa 5.5 security settings:
  package { 'net-ssh':
    ensure   => '2.7.0',
    provider => $provider,
  }

  # hashdiff 1.0.0 is not compatible with PE
  package { 'hashdiff':
    ensure   => '0.0.6',
    provider => $provider,
  }

  # nori 2.0.0 gem is not compatible with PE (nokogiri?)
  package { 'nori':
    ensure   => '1.1.5',
    provider => $provider,
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
    provider => $provider,
  }

  staging::file { 'rbvmomi.gem':
    source => 'puppet:///modules/vcenter/rbvmomi-1.6.0.z1.gem',
  } ->

  package { 'rbvmomi':
    ensure   => '1.6.0.z1',
    source   => '/opt/staging/vcenter/rbvmomi.gem',
    provider => $provider,
  }
}
