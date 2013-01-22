class vcenter::package (
) inherits vcenter::params {

  package { [
    'hashdiff',
    'rest-client',
    'gyoku',
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

  staging::file { 'rbvmomi.gem':
    source => 'puppet:///modules/vcenter/rbvmomi-1.6.0.z1.gem',
  } ->

  package { 'rbvmomi':
    ensure   => '1.6.0.z1',
    source   => '/opt/staging/vcenter/rbvmomi.gem',
    provider => $::vcenter::params::provider,
  }
}
