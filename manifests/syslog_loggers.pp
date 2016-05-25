define vcenter::syslog_loggers (
  Integer          $esxi_version             = undef,
  String           $transport_string         = undef,
  Hash             $logger_options           = {}
) {
  #Common loggers available in a ESXi machine 
  #Options are mentioned here for reference only
  #please uncomment the ones you are interested in 
  #or pass it as an option for the defined type

  $common = {
     #"Syslog.loggers.auth.rotate"             =>  "8",
     #"Syslog.loggers.auth.size"               =>  "1024",
     #"Syslog.loggers.clomd.rotate"            =>  "8",
     #"Syslog.loggers.clomd.size"              =>  "1024",
     #"Syslog.loggers.dhclient.rotate"         =>  "8",
     #"Syslog.loggers.dhclient.size"           =>  "1024",
     #"Syslog.loggers.esxupdate.rotate"        =>  "8",
     #"Syslog.loggers.esxupdate.size"          =>  "1024",
     #"Syslog.loggers.fdm.rotate"              =>  "20",
     #"Syslog.loggers.fdm.size"                =>  "5120",
     #"Syslog.loggers.hostd-probe.rotate"      =>  "8",
     #"Syslog.loggers.hostd-probe.size"        =>  "1024",
     #"Syslog.loggers.hostd.rotate"            =>  "20",
     #"Syslog.loggers.hostd.size"              =>  "2048",
     #"Syslog.loggers.hostprofiletrace.rotate" =>  "8",
     #"Syslog.loggers.hostprofiletrace.size"   =>  "1024",
     #"Syslog.loggers.lacp.rotate"             =>  "8",
     #"Syslog.loggers.lacp.size"               =>  "1024",
     #"Syslog.loggers.osfsd.rotate"            =>  "8",
     #"Syslog.loggers.osfsd.size"              =>  "1024",
     #"Syslog.loggers.rhttpproxy.rotate"       =>  "8",
     #"Syslog.loggers.rhttpproxy.size"         =>  "1024",
     #"Syslog.loggers.sdrsInjector.rotate"     =>  "8",
     #"Syslog.loggers.sdrsInjector.size"       =>  "1024",
     #"Syslog.loggers.shell.rotate"            =>  "8",
     #"Syslog.loggers.shell.size"              =>  "1024",
     #"Syslog.loggers.storageRM.rotate"        =>  "8",
     #"Syslog.loggers.storageRM.size"          =>  "1024",
     #"Syslog.loggers.swapobjd.rotate"         =>  "8",
     #"Syslog.loggers.swapobjd.size"           =>  "1024",
     #"Syslog.loggers.syslog.rotate"           =>  "8",
     #"Syslog.loggers.syslog.size"             =>  "1024",
     #"Syslog.loggers.usb.rotate"              =>  "8",
     #"Syslog.loggers.usb.size"                =>  "1024",
     #"Syslog.loggers.vmauthd.rotate"          =>  "8",
     #"Syslog.loggers.vmauthd.size"            =>  "1024",
     #"Syslog.loggers.vmkdevmgr.rotate"        =>  "8",
     #"Syslog.loggers.vmkdevmgr.size"          =>  "1024",
     #"Syslog.loggers.vmkernel.rotate"         =>  "20",
     #"Syslog.loggers.vmkernel.size"           =>  "2048",
     #"Syslog.loggers.vmkeventd.rotate"        =>  "8",
     #"Syslog.loggers.vmkeventd.size"          =>  "1024",
     #"Syslog.loggers.vmksummary.rotate"       =>  "8",
     #"Syslog.loggers.vmksummary.size"         =>  "1024",
     #"Syslog.loggers.vmkwarning.rotate"       =>  "8",
     #"Syslog.loggers.vmkwarning.size"         =>  "1024",
     #"Syslog.loggers.vobd.rotate"             =>  "8",
     #"Syslog.loggers.vobd.size"               =>  "1024",
     #"Syslog.loggers.vprobed.rotate"          =>  "8",
     #"Syslog.loggers.vprobed.size"            =>  "1024",
     #"Syslog.loggers.vprobe.rotate"           =>  "8",
     #"Syslog.loggers.vprobe.size"             =>  "1024",
     #"Syslog.loggers.vpxa.rotate"             =>  "20",
     #"Syslog.loggers.vpxa.size"               =>  "5120",
     #"Syslog.loggers.vsanSoapServer.rotate"   =>  "8",
     #"Syslog.loggers.vsanSoapServer.size"     =>  "1024",
     #"Syslog.loggers.Xorg.rotate"             =>  "8",
     #"Syslog.loggers.Xorg.size"               =>  "1024",
  }

  if $esxi_version == 5 {
     #logger options specific for ESXi Version 5
     #Options are mentioned here for reference only
     #please uncomment the ones you are interested in
     #or pass it as an option for the defined type

     $defaults = {
     #"Syslog.loggers.vmamqpd.rotate"         =>  "8",
     #"Syslog.loggers.vmamqpd.size"           =>  "1024",
    } + $common
  }
  elsif $esxi_version == 6 {
     #logger options specific for ESXi Version 6
     #Options are mentioned here for reference only
     #please uncomment the ones you are interested in
     #or pass it as an option for the defined type

     $defaults = {
     #"Syslog.loggers.ddecomd.rotate"          =>  "8",
     #"Syslog.loggers.ddecomd.size"            =>  "1024",
     #"Syslog.loggers.epd.rotate"              =>  "8",
     #"Syslog.loggers.epd.size"                =>  "1024",
     #"Syslog.loggers.iofiltervpd.rotate"      =>  "8",
     #"Syslog.loggers.iofiltervpd.size"        =>  "1024",
     #"Syslog.loggers.nfcd.rotate"             =>  "8",
     #"Syslog.loggers.nfcd.size"               =>  "1024",
     #"Syslog.loggers.rabbitmqproxy.rotate"    =>  "8",
     #"Syslog.loggers.rabbitmqproxy.size"      =>  "1024",
     #"Syslog.loggers.vsanmgmt.rotate"         =>  "8",
     #"Syslog.loggers.vsanmgmt.size"           =>  "1024",
     #"Syslog.loggers.vsantraceUrgent.rotate"  =>  "8",
     #"Syslog.loggers.vsantraceUrgent.size"    =>  "1024",
     #"Syslog.loggers.vvold.rotate"            =>  "16",
     #"Syslog.loggers.vvold.size"              =>  "8192",
     } + $common
  }

  #Override the defaults with custom settings 
  $merged_hash = $defaults + $logger_options
  
  #Enable to debug
  #notice ("Transport: $transport_string")
  #notice ("Default Hash: $logger_options")
  #notice ("Merged Hash: $merged_hash")

  esx_advanced_options{"$name":
    options     => $merged_hash,
    transport   => Transport[$transport_string],
  }
}

