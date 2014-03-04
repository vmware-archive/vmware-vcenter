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
    transport                      => Transport['vcenter'],
    operation                      => $newVM['operation'],
    datacenter_name                => $newVM['datacenter'],
    memorymb                       => $newVM['memoryMB'],
    numcpu                         => $newVM['numCPU'],
    host                           => $newVM['host'],
    cluster                        => $newVM['cluster'],
    target_datastore               => $newVM['target_datastore'],
    diskformat                     => $newVM['diskformat'],
        
    # Create VM Parameters
    # disk size should be in KB
    disksize                       => $createVM['disksize'],
    memory_hot_add_enabled         => $createVM['memory_hot_add_enabled'],
    cpu_hot_add_enabled            => $createVM['cpu_hot_add_enabled'],
    # user can get the guestif from following url
    # http://pubs.vmware.com/vsphere-55/index.jsp?topic=%2Fcom.vmware.wssdk.apiref.doc%2Fvim.vm.GuestOsDescriptor.GuestOsIdentifier.html
    guestid                        => $createVM['guestid'],
    portgroup                      => $createVM['portgroup'],
    nic_count                      => $createVM['nic_count'],
    nic_type                       => $createVM['nic_type'],
    scsi_controller_type           => $createVM['scsi_controller_type'],

    # Clone VM parameters
    goldvm                         => $goldVMName['name'],
    dnsdomain                      => $cloneVM['dnsDomain'],

    #Guest OS nic specific params
    nicspec => {
        nic => [{
            ip        => $cloneVM['ip1'],
            subnet    => $cloneVM['subnet1'],
            dnsserver => $cloneVM['dnsserver1'],
            gateway   => $cloneVM['gateway1']
        },{
            ip        => $cloneVM['ip2'],
            subnet    => $cloneVM['subnet1'],
            dnsserver => $cloneVM['dnsserver1'],
            gateway   => $cloneVM['gateway1']
        }],
    },

    #Guest Customization Params
    guestcustomization              => $cloneVM['guestCustomization'],
    guesthostname                   => $cloneVM['guesthostname'],
    guesttype                       => $cloneVM['guesttype'],
    #Linux guest os specific
    linuxtimezone                   => $cloneVM['linuxtimezone'],
    #Windows guest os specific
    windowstimezone                 => $cloneVM['windowstimezone'],
    guestwindowsdomain              => $cloneVM['guestwindowsdomain'],
    guestwindowsdomainadministrator => $cloneVM['guestwindowsdomainadministrator'],
    guestwindowsdomainadminpassword => $cloneVM['guestwindowsdomainadminpassword'],
    windowsadminpassword            => $cloneVM['windowsadminpassword'],
    productid                       => $cloneVM['productid'],
    windowsguestowner               => $cloneVM['windowsguestowner'],
    windowsguestorgnization         => $cloneVM['windowsguestorgnization'],
    customizationlicensedatamode    => $cloneVM['customizationlicensedatamode'],
    autologon                       => $cloneVM['autologon'],
    autologoncount                  => $cloneVM['autologoncount'],
    autousers                       => $cloneVM['autousers'],
    
}
