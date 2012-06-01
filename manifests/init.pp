class vcenter (
  $media             = 'D:\\',
  $sql_media         = 'D:\\',
  $username          = 'VCENTER',
  $password          = 'vCenter2008demo',
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
    command => "${sqlcmd} -Q \"if not exists(select * from sys.databases where name='vcenter') create database [vcenter]; alter database [vcenter] set recovery simple;\"",
    path    => $::path,
    require => Class['mssql'],
  }

  registry_key { [ 'HKLM\SOFTWARE\ODBC',
                   'HKLM\SOFTWARE\ODBC\ODBC.INI',
                   'HKLM\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources',
                   'HKLM\SOFTWARE\ODBC\ODBC.INI\VMware VirtualCenter' ]:
    ensure => present,
  }

  Registry::Value {
    notify  => Exec['create_database'],
  }

  registry::value { 'VMware VirtualCenter':
    key   => 'HKLM\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources',
    value => 'SQL Server Native Client 10.0',
    type  => string,
  }

  registry::value { 'Driver':
    key   => 'HKLM\SOFTWARE\ODBC\ODBC.INI\VMware VirtualCenter',
    value => "C:\\Windows\\system32\\sqlncli10.dll",
    type  => string,
  }

  registry::value { 'Server':
    key   => 'HKLM\SOFTWARE\ODBC\ODBC.INI\VMware VirtualCenter',
    value => '(local)',
    type  => string,
  }

  registry::value { 'Database':
    key   => 'HKLM\SOFTWARE\ODBC\ODBC.INI\VMware VirtualCenter',
    value => 'vcenter',
    type  => string,
  }

  registry::value { 'LastUser':
    key   => 'HKLM\SOFTWARE\ODBC\ODBC.INI\VMware VirtualCenter',
    value => 'Administrator',
    type  => string,
  }

  registry::value { 'Trusted_Connection':
    key   => 'HKLM\SOFTWARE\ODBC\ODBC.INI\VMware VirtualCenter',
    value => 'Yes',
    type  => string,
  }

  exec { 'install_vCenter':
    command => 'vCenter-Server\\VMware-vcserver.exe /s /w /L1033 /v"/qr USERNAME=Administrator COMPANYNAME=Puppet DB_SERVER_TYPE=Custom DB_DSN=\"VMWARE VirtualCenter\" DB_DSN_WINDOWS_AUTH=1 FORMAT_DB=1"',
    path    => $media,
    timeout => 900,
  }

  if $client {
    exec { 'install_vSphere_client':
      command => 'vSphere-Client\\VMware-viclient.exe /s /w /L1033 /v" /qr"',
      path    => $media,
      timeout => 300,
      require => Exec['install_vCenter'],
    }
  }

}
