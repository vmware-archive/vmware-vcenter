class vcenter::package (
) inherits vcenter::params {
  package { [
    'hashdiff',
    'rest-client',
    'rbvmomi',
    'gyoku',
  ]:
    ensure   => present,
    provider => $::vcenter::params::provider,
  }

  # nori 2.0.0 gem is not compatible with PE (nokogiri?)
  package { 'nori':
    ensure   => '1.1.3',
    provider => $::vcenter::params::provider,
  }
}

