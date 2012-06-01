class vcenter (
  $media             = 'D:\\',
  $sql_media         = 'D:\\',
  $username          = 'VCENTER',
  $password          = 'vC3nt!2008demo',
  $jvm_memory_option = 'S',
  $client            = true
) {

  user { $username:
    comment  => 'VMware vCenter account.',
    groups   => ['Administrators'],
    password => $password,
  }

  class { 'mssql':
    features => 'SQL,CONN,SSMS,ADV_SSMS',
    media    => $sql_media,
    admin    => "Administrator\" \"${username}",
    require  => User['VCENTER'],
  }

  service { 'SQLSERVERAGENT':
    ensure  => running,
    require => Class['mssql'],
  }

  $sqlcmd = '"C:\Program Files\Microsoft SQL Server\100\Tools\Binn\sqlcmd.exe"'

  exec { 'create_database':
    command     => "${sqlcmd} -Q \"if not exists(select * from sys.databases where name='vcenter') create database [vcenter]; alter database [vcenter] set recovery simple;\"",
    path        => $::path,
    refreshonly => true,
    subscribe   => Class['mssql'],
  }

  registry_key { [ 'HKLM\SOFTWARE\ODBC',
                   'HKLM\SOFTWARE\ODBC\ODBC.INI' ]:
    ensure => present,
  }

  Registry::Value {
    key   => 'HKLM\SOFTWARE\ODBC\ODBC.INI\VMware VirtualCenter',
    notify => Exec['create_database'],
    before => Exec['install_vCenter'],
  }

  registry::value { 'VMware VirtualCenter':
    key   => 'HKLM\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources',
    value => 'VMware VirtualCenter',
    data  => 'SQL Server Native Client 10.0',
    type  => string,
  }

  registry::value { 'Driver':
    value => 'Driver',
    data  => "C:\\Windows\\system32\\sqlncli10.dll",
    type  => string,
  }

  registry::value { 'Server':
    value => 'Server',
    data  => '(local)',
    type  => string,
  }

  registry::value { 'Database':
    value => 'Database',
    data  => 'vcenter',
    type  => string,
  }

  registry::value { 'LastUser':
    value => 'LastUser',
    data  => 'Administrator',
    type  => string,
  }

  registry::value { 'Trusted_Connection':
    value => 'Trusted_Connection',
    data  => 'Yes',
    type  => string,
  }

  exec { 'install_vCenter':
    command => 'vCenter-Server\\VMware-vcserver.exe /s /w /L1033 /v"/qr USERNAME=Administrator COMPANYNAME=Puppet DB_SERVER_TYPE=Custom DB_DSN=\"VMWARE VirtualCenter\" DB_DSN_WINDOWS_AUTH=1 FORMAT_DB=1"',
    creates => 'C:\Program Files\VMware\Infrastructure\VirtualCenter Server',
    path    => $media,
    timeout => 1200,
    require => Class['mssql'],
  }

  if $client {
    exec { 'install_vSphere_client':
      command => 'vSphere-Client\\VMware-viclient.exe /s /w /L1033 /v" /qr"',
      creates => 'C:\Program Files (x86)\VMware\Infrastructure\Virtual Infrastructure Client',
      path    => $media,
      timeout => 600,
      require => Exec['install_vCenter'],
    }
  }

  package { 'rbvmomi':
    ensure   => present,
    provider => gem,
  }

}
