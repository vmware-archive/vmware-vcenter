# Copyright (C) 2013 VMware, Inc.

require 'pathname' # WORK_AROUND #14073 and #7788
module_lib = Pathname.new(__FILE__).parent.parent.parent.parent

require File.join module_lib, 'puppet/provider/vcenter'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet_x/vmware/util'

Puppet::Type.type(:vc_dvswitch_migrate).provide( :vc_dvswitch_migrate, 
                     :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages Distributed Virtual Switch migration on an ESXi host"\
         "by moving vmknics and vmnics from standard to distributed switch"

  def vmk_get vmknic
    vnic = find_vmknic vmknic

    if (pg = vnic.portgroup) && pg != ""
      pg
    elsif (pgKey = vnic.spec.distributedVirtualPort.portgroupKey)
      (dvpg_by_key pgKey).name
    else
      nil
    end
  end

  def find_vmknic vmknic
    result = host.configManager.networkSystem.networkConfig.vnic.find{ |v|
      v.device = vmknic
    }
    result or fail "#{host.name}: #{vmknic} not found"
  end

  def vmk_set vmknic, pg_name
    # create request to move vmknic to portgroup on dvswitch
    hostNetworkConfig.vnic <<
      RbVmomi::VIM.HostVirtualNicConfig(
        :changeOperation => 'edit',
        :device => vmknic,
        :portgroup => '',
        :spec => RbVmomi::VIM.HostVirtualNicSpec(
          :distributedVirtualPort =>
            RbVmomi::VIM.DistributedVirtualSwitchPortConnection(
              :switchUuid => dvswitch.uuid,
              :portgroupKey => (dvpg_by_name pg_name).key
            )
        )
      )

    # create request to remove old portgroup from standard switch
    hostNetworkConfig.portgroup <<
      RbVmomi::VIM.HostPortGroupConfig(
        :changeOperation => 'remove',
        :spec => RbVmomi::VIM.HostPortGroupSpec(
          :name => (self.send vmknic.to_sym),
          # add some properties required by wsdl
          :vlanId => -1,
          :vswitchName => '',
          :policy => RbVmomi::VIM.HostNetworkPolicy
        )
      )

    @flush_required = true
  end

  def vmnic_get vmnic
    # nil is valid - some vmnics (pnics) may be unassigned
    pg_name = nil

    # There is no portgroup for uplinks on standard switch; use 
    # the switch name so the change message will make sense.
    host.configManager.networkSystem.networkConfig.
      vswitch.each do |vss|
        # bridge type determines if nicDevice is string or array
        nicDevice = Array vss.spec.bridge.nicDevice
        pg_name = vss.name if nicDevice.include? vmnic
      end

    pg_name || host.configManager.networkSystem.networkConfig.
      proxySwitch.each do |pxsw|
        pnicSpec = pxsw.spec.backing.pnicSpec.
          find{|pnic| pnic.pnicDevice == vmnic}
        pg_name = (dvpg_by_key pnicSpec.uplinkPortgroupKey).name if pnicSpec
      end

    pg_name
  end

  def vmnic_set vmnic, pg_name
    msg = "#{vmnic}: \"#{dvswitch.name}\" has no uplink "\
          "portgroup \"#{pg_name}\""
    pg = dvswitch.config.uplinkPortgroup.find{|ulpg|
          ulpg.name == pg_name
        } || (fail msg)

    # create request to move vminc to portgroup on dvswitch
    hostNetworkConfig.proxySwitch[0].spec.backing.pnicSpec <<
      RbVmomi::VIM.DistributedVirtualSwitchHostMemberPnicSpec(
        :pnicDevice => vmnic,
        :uplinkPortgroupKey => pg.key
      )
    # add vmnic to list to be removed from standard switch
    migrating_pnic << vmnic

    @flush_required = true
  end

  ('0'..'31').each do |i|
    vmk_port = 'vmk'+i
    define_method(vmk_port) do
      vmk_get vmk_port
    end

    define_method(vmk_port+'=') do |pg_name|
      vmk_set vmk_port, pg_name
    end

    vmnic = 'vmnic'+i
    define_method(vmnic) do
      vmnic_get vmnic
    end

    define_method(vmnic+'=') do |pg_name|
      vmnic_set vmnic, pg_name
    end
  end

  def flush_prep
    # remove properties from request if not changed by user
    hostNetworkConfig.props.delete :proxySwitch if
      hostNetworkConfig.proxySwitch[0].spec.backing.pnicSpec.empty?
    hostNetworkConfig.props.delete :vnic if
      hostNetworkConfig.vnic.empty?
    hostNetworkConfig.props.delete :portgroup if
      hostNetworkConfig.portgroup.empty?

    # find standard switches from which uplinks will 
    # be removed; add the changes to the request
    if migrating_pnic.size > 0
      hostNetworkConfig.vswitch = []
      host.configManager.networkSystem.networkConfig.vswitch.each do |sw|
        if RbVmomi::VIM::HostVirtualSwitchBondBridge === sw.spec.bridge
          # standard switch for multiple uplinks
          if (sw.spec.bridge.nicDevice & migrating_pnic).size > 0
            sw.changeOperation = 'edit'
            sw.spec.bridge.nicDevice -= migrating_pnic
            sw.spec.bridge = nil if sw.spec.bridge.nicDevice.empty?
            sw.spec.policy.nicTeaming.nicOrder.activeNic -= migrating_pnic
            sw.spec.policy.nicTeaming.nicOrder.standbyNic -= migrating_pnic
            hostNetworkConfig.vswitch << sw
          end
        else
          # standard switch for single uplink
          if migrating_pnic.include? sw.spec.bridge.nicDevice
            fail "unexpected standard switch with simple bridge"
            # ? sw.spec.bridge.nicDevice = '' ?
          end
        end
      end
    end

    hostNetworkConfig
  end

  def flush
    return unless @flush_required
    config = flush_prep
    host.configManager.networkSystem.UpdateNetworkConfig(
      :changeMode => :modify,
      :config => config
    )
  end

  private

  def hostNetworkConfig
    @hostNetworkConfig ||=
      RbVmomi::VIM::HostNetworkConfig.new(
        :proxySwitch => [
          RbVmomi::VIM.HostProxySwitchConfig(
            :changeOperation => 'edit',
            :uuid => dvswitch.uuid,
            :spec => RbVmomi::VIM.HostProxySwitchSpec(
              # copy backing from current config so 
              # can be added to existing pnics
              :backing => proxyswitch.spec.backing
            )
          )
        ],
        :portgroup => [],
        :vnic => []
      )
  end

  def migrating_pnic
    @migrating_pnic ||= []
  end

  def host
    @host ||= find_host
  end

  def find_host
    result = vim.searchIndex.FindByDnsName(
      :dnsName => resource[:host], :vmSearch => false
    )
    result or fail "host \"#{resource[:host]}\" not found"
  end

  def proxyswitch
    # find proxyswitch corresponding to dvswitch being configured
    @proxySwitch ||= find_proxyswitch dvs_name
  end

  def find_proxyswitch(name)
    error_msg = "host \"#{resource[:host]}\" is not a member of "\
      "dvswitch \"#{resource[:dvswitch]}\""
    result = host.configManager.networkSystem.networkInfo.proxySwitch.find{ |pxsw|
      pxsw.dvsName == name
    }
    result or fail error_msg
  end

  def datacenter
    @datacenter ||= find_datacenter
  end

  def find_datacenter
    entity = host
    while entity = entity.parent
      if entity.class == RbVmomi::VIM::Datacenter
        break entity
      elsif entity == rootfolder
        fail "no datacenter found for host \"#{resource[:host]}\""
      end
    end
  end

  def dvswitch
    @dvswitch ||= find_dvswitch dvs_name
  end

  def find_dvswitch(name)
    result = datacenter.networkFolder.children.select{ |net|
      RbVmomi::VIM::VmwareDistributedVirtualSwitch === net
    }.find{ |net|
      net.name == name
    }
    result or fail "dvswitch \"#{resource[:dvswitch]}\"not found"
  end

  def dvs_name
    resource[:dvswitch].split('/').last
  end

  def dvpg_list
    @dvpg_list ||= find_dvpg_list
  end

  def find_dvpg_list
    result = datacenter.network.select{ |pg|
      RbVmomi::VIM::DistributedVirtualPortgroup === pg
    }
    result || []
  end

  def dvpg_by_name name
    error_msg = "dvportgroup \"#{name}\" not found in dvswitch \"#{dvswitch.name}\""
    result = dvpg_list.find{ |pg|
      pg.config.name == name &&
        pg.config.distributedVirtualSwitch.uuid == dvswitch.uuid
    }
    result or fail error_msg
  end

  def dvpg_by_key key
    error_msg = "dvportgroup \"#{key}\" not found in dvswitch \"#{dvswitch.name}\""
    result = dvpg_list.find{ |pg|
      pg.key == key &&
        pg.config.distributedVirtualSwitch.uuid == dvswitch.uuid
    }
    result or fail error_msg
  end

end
