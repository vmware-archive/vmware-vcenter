class vcenter::package (
) inherits vcenter::params {
  package { [
    'hashdiff',
    'rest-client',
    'rbvmomi',
    'nori',
    'gyoku',
  ]:
    ensure   => present,
    provider => $::vcenter::params::provider,
  }
}

