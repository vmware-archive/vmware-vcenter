import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

#Equivalent ESXCli Commands
###########################
#Change the individual syslog rotation count
#esxcli system syslog config logger set --id=hostd --rotate=20 --size=2048
#esxcli system syslog config logger set --id=vmkernel --rotate=20 --size=2048
#esxcli system syslog config logger set --id=fdm --rotate=20 --size=2048
#esxcli system syslog config logger set --id=vpxa --rotate=20 --size=2048


#Defined type wrapper to manage esxi syslog loggers via puppet
vcenter::syslog_loggers { $esx1['hostname']:
  esxi_version                              => 6,         #version can be 5 or 6
  transport_string                          => 'vcenter', #use the same transport string
  logger_options                            => {
    "Syslog.loggers.hostd.rotate"           => 20,
    "Syslog.loggers.hostd.size"             => 2048,
    "Syslog.loggers.vmkernel.rotate"        => 20,
    "Syslog.loggers.vmkernel.size"          => 2048,
    "Syslog.loggers.fdm.rotate"             => 20,
    "Syslog.loggers.fdm.size"               => 2048,
    "Syslog.loggers.vpxa.rotate"            => 20,
    "Syslog.loggers.vpxa.size"              => 2048,
  }
}

