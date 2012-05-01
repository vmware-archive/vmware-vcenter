class vcenter (
  $media             = 'D:\\',
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
    admin    => "Administrator\" \"${username}",
    require  => User['VCENTER'],
  }

  file { 'c:\\odbc.reg':
    content => template('vcenter/odbc.reg.erb'),
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

  # Obsolete packages.
  # staging::file { 'sqlncli.msi':
  #   source => 'http://go.microsoft.com/fwlink/?LinkId=123718&clcid=0x409'
  # }

  # package { 'SQL_native_client':
  #   ensure => present,
  #   source => 'C:\\Programdata\\PuppetLabs\\staging\\windows\sqlncli.msi',
  #   require => Staging::File['sqlncli.msi'],
  # }

  exec { 'vCenter_ODBC':
    command   => 'C:\Windows\SysNative\cmd.exe /C "regedit /S c:\\odbc.reg"',
    path      => $::path,
    require   => File['c:\\odbc.reg'],
    subscribe => Exec['create_database'],
  }

  exec { 'install_vCenter':
    command => 'vCenter-Server\\VMware-vcserver.exe /s /w /L1033 /v"/qr USERNAME=Administrator COMPANYNAME=Puppet DB_SERVER_TYPE=Custom DB_DSN=\"VMWARE VirtualCenter\" DB_DSN_WINDOWS_AUTH=1 FORMAT_DB=1"',
    path    => $media,
    timeout => 900,
    require => Exec['vCenter_ODBC'],
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
