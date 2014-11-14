# Copyright (C) 2014 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
} ->

esx_system_resource { 'esx1_system_resource1':
  host                          => $esx1['hostname'],
  system_resource               => $systemResource['name'],
  cpu_limit                     => $systemResource['cpuLimit'],
  #cpu_unlimited                 => $systemResource['cpuUnlimited'],
  cpu_reservation               => $systemResource['cpuReservation'],
  cpu_expandable_reservation    => $systemResource['cpuExpandableReservation'],
  memory_limit                  => $systemResource['memLimit'],
  #memory_unlimited              => $systemResource['memUnlimited'],
  memory_reservation            => $systemResource['memReservation'],
  memory_expandable_reservation => $systemResource['memExpandableReservation'],
  transport                     => Transport['vcenter'],
}
