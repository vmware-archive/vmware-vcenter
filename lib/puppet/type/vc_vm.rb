# Copyright (C) 2013 VMware, Inc.
module_lib = Pathname.new(__FILE__).parent.parent.parent
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
require File.join module_lib, 'puppet_x/vmware/mapper'
require File.join vmware_module.path, 'lib/puppet/property/vmware'

Puppet::Type.newtype(:vc_vm) do
  @doc = 'Manage vCenter VMs.'

  ensurable do
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.destroy
    end
    defaultto(:present)
  end

  newparam(:name, :namevar => true) do
    desc 'The virtual machine name.'
    newvalues(/.+/)
  end

  newparam(:datacenter) do
    desc 'Name of the datacenter.'
    newvalues(/.+/)
  end

  newparam(:memory_mb) do
    desc 'Amount of memory to be assigned to provisioned VM.'
    defaultto(1024)
    munge do |value|
      Integer(value)
    end
  end

  newparam(:num_cpus) do
    desc "Number of CPU's assigned to the new Virtual Machine."
    defaultto(1)
    munge do |value|
      Integer(value)
    end
  end

  newparam(:cluster) do
    desc 'Name of the cluster.'
  end

  newparam(:host) do
    desc 'Name of the host.'
  end

  newparam(:target_datastore) do
    desc 'Name of the target datastore.'
    munge do |value|
      resource[:datastore] = value
      Puppet.warn('target_datastore parameter deprecated')
      value
    end
  end

  newparam(:datastore) do
  end

  newparam(:datastore_cluster) do
  end


  newparam(:disk_format) do
    desc 'Name of the target datastore.'
    newvalues(:thin, :thick)
    defaultto(:thin)
  end

  # parameters for create vm operation
  newparam(:disk_size) do
    desc 'Capacity of the virtual disk (in KB).'
    defaultto(4096)
    munge do |value|
      Integer(value)
    end
  end

  newparam(:memory_hot_add_enabled) do
    desc 'Indicates whether or not memory can be added to the virtual machine while it is running'
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:cpu_hot_add_enabled) do
    desc 'Indicates whether or not cpu can be added to the virtual machine while it is running'
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:guestid) do
    desc 'Guest operating system identifier. User can get the guestid from following url +
    http://pubs.vmware.com/vsphere-55/index.jsp?topic=%2Fcom.vmware.wssdk.apiref.doc%2Fvim.vm.GuestOsDescriptor.GuestOsIdentifier.html'
    defaultto('otherGuest')
  end

  newproperty(:network_interfaces, :parent => Puppet::Property::VMware_Array_Hash, :key => 'portgroup', :array_matching => :all ) do
    desc 'Network Interfaces consist of a portgroup and nic_type'
    defaultto([])
  end

  newparam(:scsi_controller_type) do
    desc 'Virtual SCSI controller type for new Virtual Machine''s boot disk.'
    newvalues('BusLogic Parallel', 'LSI Logic SAS', 'LSI Logic Parallel' ,'VMware Paravirtual')
    defaultto(:'LSI Logic SAS')
  end

  # parameters for clone vm operation
  newparam(:template) do
    desc 'Template to clone from'
    munge do |value|
      if value.include?('/')
        datacenter, template = value.split('/')
      else
        template = value
      end

      resource[:template_datacenter] ||= datacenter || resource[:datacenter]

      template
    end
  end

  newparam(:template_datacenter) do
    desc "Template datacenter."
  end

  newparam(:domain) do
    desc 'domain name.'
  end

  newparam(:nicspec) do
    desc "This parameter holds follwoing virtual NICs specification parameter values.+
            ip: Static IP address to the Virtual Machine. If left blank, the module uses the DHCP to set the IP address.+
            subnet: Default subnet mask on the NICs.+
            gateway: Default Gateway on the NIC.+
            dnsserver: DNS servers on the NICs."
  end

  # Guest Customization params
  newparam(:guest_customization ) do
    desc 'Enable guest customization'
    newvalues(:true, :false)
    defaultto(:false)
  end

  newparam(:guest_type) do
    desc 'Guest VM OS type'
    newvalues(:windows, :linux)
    defaultto(:windows)
  end

  newparam(:timezone) do
    desc 'Guest timezone, use integer value for Windows and name for Linux.'
    defaultto(:GMT)
    munge do |value|
      case resource[:guest_type]
      when :windows
        case value
        when :GMT
          35
        else
          Integer(value)
        end
      when :linux
        case value
        when :GMT
          'GMT'
        else
          value.upcase
        end
      end
    end
  end

  # Windows Customization
  newparam(:domain_admin) do
    desc 'Windows: guest domain administrator username'
    defaultto('')
  end

  newparam(:domain_password) do
    desc 'Windows: guest domain administrator password'
    defaultto('')
  end

  newparam(:admin_password) do
    desc 'Windows: local administrator password'
    defaultto('')
  end

  newparam(:product_id) do
    desc 'Windows: product ID'
  end

  newparam(:full_name) do
    desc 'Windows: product owner name'
  end

  newparam(:org_name) do
    desc 'Windows: product organization name'
    dvalue = 'TestOrg'
    defaultto(dvalue)
  end

  newparam(:license_mode) do
    desc 'Windows: product license mode (perSeat or perServer)'
    newvalues(:perSeat, :perServer)
    defaultto(:perServer)
  end

  newparam(:license_users) do
    desc 'This key is valid only if customizationlicensedatamode = perServer. The integer value indicates the number of client licenses purchased for the VirtualCenter server being installed. '
    defaultto(1)
    munge{ |value| Integer(value) }
  end

  newparam(:autologon) do
    desc 'Flag to determine whether or not the machine automatically logs on as Administrator.'
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:autologon_count) do
    desc 'If the AutoLogon flag is set, then the AutoLogonCount property specifies the number of times the machine should automatically log on as Administrator.'
    defaultto(1)
    munge{ |value| Integer(value) }
  end

  newparam(:graceful_shutdown) do
    desc 'Perform a graceful shutdown if possible.  This parameter has no effect unless :power_state is set to :poweredOff'
    newvalues(:true, :false)
    defaultto(:true)
  end

  newproperty(:power_state) do
    desc 'set the powerstate for the vm to either poweredOn/poweredOff/reset/suspended, for poweredOff, if tools is running a shutdownGuest will be issued, otherwise powerOffVM_TASK'
    newvalues(:poweredOn, :poweredOff, :reset, :suspended)
  end
end
