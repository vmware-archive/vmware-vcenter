# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vc_vm { $newVM['vmName']:
    ensure                         => $newVM['ensure'],
    datacenter_name                => $newVM['datacenter'],
    goldvm                         => $goldVMName['name'],
    memorymb                       => $newVM['memoryMB'],
    dnsdomain                      => $newVM['dnsDomain'],
    numcpu                         => $newVM['numCPU'],
    transport                      => Transport['vcenter'],
    host                           => $newVM['host'],
    cluster                        => $newVM['cluster'],
    diskformat                     => $newVM['diskformat'],
    #Guest Customization Params
    guestcustomization             => $newVM['guestCustomization'],
    guesthostname                  => $newVM['guesthostname'],
    guesttype                      => $newVM['guesttype'],
    #Linux guest os specific
    linuxtimezone                  => $newVM['linuxtimezone'],
    #Windows guest os specific
    windowstimezone                => $newVM['windowstimezone'],
    guestwindowsdomain             => $newVM['guestwindowsdomain'],
  guestwindowsdomainadministrator  => $newVM['guestwindowsdomainadministrator'],
  guestwindowsdomainadminpassword  => $newVM['guestwindowsdomainadminpassword'],
  windowsadminpassword             => $newVM['windowsadminpassword'],
  productid                        => $newVM['productid'],
  windowsguestowner                => $newVM['windowsguestowner'],
  windowsguestorgnization          => $newVM['windowsguestorgnization'],
  customizationlicensedatamode     => $newVM['customizationlicensedatamode'],
                         autologon => $newVM['autologon'],
                    autologoncount => $newVM['autologoncount'],
					autousers      => $newVM['autousers'],

  #Guest OS nic specific params
  nicspec => {
    nic => [{
      ip        => $newVM['ip1'],
      subnet    => $newVM['subnet1'],
      dnsserver => $newVM['dnsserver1'],
      gateway   => $newVM['gateway1']
    },{
      ip        => '172.21.95.81',
      subnet    => $newVM['subnet1'],
      dnsserver => $newVM['dnsserver1'],
      gateway   => $newVM['gateway1']
    },{
      ip        => '172.21.95.82',
      subnet    => $newVM['subnet1'],
      dnsserver => $newVM['dnsserver1'],
      gateway   => $newVM['gateway1']
    },{
      ip        => '172.21.95.83',
      subnet    => $newVM['subnet1'],
      dnsserver => $newVM['dnsserver1'],
      gateway   => $newVM['gateway1']
    }],
  }
}
