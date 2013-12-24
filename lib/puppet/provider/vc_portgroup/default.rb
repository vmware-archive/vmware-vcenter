# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'
Puppet::Type.type(:vc_portgroup).provide(:vc_portgroup, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter Port Groups of vSwitch"
	def create
    # TODO: Create Port Group Method.
    	Puppet.debug "Entered in Create PortGroup."
		begin
    		create_port_group 
		rescue Exception => excep
			Puppet.err excep.message
		end
  	end

	def destroy
		Puppet.debug "Entered in destroy PortGroup"
		begin
			remove_port_group
		rescue Exception => excep
    		Puppet.err excep.message
		end
  	end

	def exists?
		Puppet.debug "Entered in exists?"
    	find_port_group == true
	end


	def vlanid
		Puppet.debug "Retrieving vlan Id associated to the given port group"
		begin
    		@host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
		if @host.nil?
    		raise Puppet::Error, "No Host in datacenter #{walk_dc}" unless @host
		end
		    @networksystem=@host.configManager.networkSystem
    		@pg = @networksystem.networkInfo.portgroup
	    	for portg in (@pg) do
    	    	availablepgs = portg.spec.name
        		if (availablepgs == resource[:name])
					vlanid=portg.spec.vlanId
					return vlanid
				end
			end
		rescue Exception => excep
			Puppet.err excep.message
		end
	end
	
	def vlanid=(value)
		Puppet.debug "Updating vlan Id associated to the given port group"
		begin
	    	@host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
			if @host.nil?
    			raise Puppet::Error, "No Host in datacenter #{walk_dc}" unless @host
			end
    		@networksystem=@host.configManager.networkSystem
	    	@pg = @networksystem.networkInfo.portgroup
	    	for portg in (@pg) do
    	    	availablepgs = portg.spec.name
	    	    if (availablepgs == resource[:name])
			if (find_vswitch == false)
				raise Puppet::Error, "Please provide valid vswitch"
			end	
		    	    hostportgroupspec = RbVmomi::VIM.HostPortGroupSpec(:name => resource[:name], :policy => portg.spec.policy, :vlanId => resource[:vlanid], :vswitchName => resource[:vswitchname])
        	    	@networksystem.UpdatePortGroup(:pgName => resource[:name], :portgrp => hostportgroupspec)
				end
			end
    	rescue Exception => excep
			Puppet.err excep.message
		end
	end

	def vmotion
		Puppet.debug "Retrieving vmotion status flag of given port group"
		begin
			return "needtochange"
        rescue Exception => excep
            Puppet.err excep.message
		end
	end

	def vmotion=(value)
		Puppet.debug "Updating vmotion status flag of given port group"
		begin
		setupvmotion	
        rescue Exception => excep
            Puppet.err excep.message
		end
	end

	#ipconfig getter
	def ipconfig
    	Puppet.debug "Retrieving ip configuration of given port group"
		begin
        	@host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
			if @host.nil?
    			raise Puppet::Error, "No Host in datacenter #{walk_dc}" unless @host
			end
    	    @networksystem=@host.configManager.networkSystem
        	vnics=@networksystem.networkInfo.vnic

        	for vnic in (vnics)
	            if (vnic.portgroup && resource[:name] == vnic.portgroup)
	                if (resource[:ipconfig] == :manual)
    	                ipaddressonportgroup = vnic.spec.ip.ipAddress
        	            subnetmaskonportgroup = vnic.spec.ip.subnetMask
            	        Puppet.debug "ipaddressonportgroup=#{ipaddressonportgroup},subnetMask=#{subnetmaskonportgroup}"
  				        if (ipaddressonportgroup != resource[:ipaddress] || subnetmaskonportgroup != resource[:subnetmask])
          					return "false"
				        elsif  (ipaddressonportgroup == resource[:ipaddress] && subnetmaskonportgroup == resource[:subnetmask])
        				    return "manual"
							#return same as manifest file i.e  manual because the port group has same values hence no need to go ito setter
            			end
                	elsif (resource[:ipconfig] == :automatic)
	         			dhcpflagonportgroup = vnic.spec.ip.dhcp
    	       			Puppet.debug "dhcpflagonportgroup=#{dhcpflagonportgroup}"
        	    		if (dhcpflagonportgroup == false)
              				return "false"
            			elsif (dhcpflagonportgroup == true)
              				return "automatic"
            			end
                	end
          		end
      		end
			Puppet.debug "coming falsely here"
			return "false"
        rescue Exception => excep
            Puppet.err excep.message
		end
	end

	#ipconfig setter
	def ipconfig=(value)
    	Puppet.debug "Updating ip configuration of given port group"
		begin
        	@host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
			if @host.nil?
    			raise Puppet::Error, "No Host in datacenter #{walk_dc}" unless @host
			end
    	    @networksystem=@host.configManager.networkSystem
        	vnics=@networksystem.networkInfo.vnic
        	@vmotionsystem = @host.configManager.vmotionSystem

        	for vnic in (vnics)
	        	if (vnic.portgroup && resource[:name] == vnic.portgroup)
					#slecting vnic for vmotion first to update ip configuration
					vnicdevice=vnic.device
					@vmotionsystem.SelectVnic(:device => vnicdevice)

	            	if (resource[:ipconfig] == :manual)
						if (resource[:ipaddress] == nil || resource[:subnetmask] == nil)
					    	raise Puppet::Error, "Please provide ipaddress and subnet mask"
						elsif( resource[:ipaddress].length == 0 || resource[:subnetmask].length == 0)
							raise Puppet::Error, "Please provide valid ipaddress and subnet mask"
						end
                    	ipconfiguration=RbVmomi::VIM.HostIpConfig(:dhcp => 0, :ipAddress => resource[:ipaddress], :subnetMask => resource[:subnetmask])
						Puppet.debug "going for manual settings"
	                    @vmotionsystem.UpdateIpConfig(:ipConfig => ipconfiguration)
    	            elsif (resource[:ipconfig] == :automatic)
   	    	        	Puppet.debug "coming in automatic setting"
						ipconfiguration = RbVmomi::VIM.HostIpConfig(:dhcp => 1)
                    	@vmotionsystem.UpdateIpConfig(:ipConfig => ipconfiguration)
	        		end
        		end
			end
			return "true"
       rescue Exception => excep
            Puppet.err excep.message
       end
	end


	#Get the traffic shapping policy.
	def traffic_shaping_policy
    	Puppet.debug "Retrieving the traffic shaping policy of given port group."
		begin
    		@host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
			if @host.nil?
    			raise Puppet::Error, "No Host in datacenter #{walk_dc}" unless @host
			end
		    #raise Puppet:Error, "No Host in datacenter #{walk_dc}" unless @host
		    @networksystem=@host.configManager.networkSystem
		    @pg = @networksystem.networkInfo.portgroup
		    for portg in (@pg) do
    			availablepgs = portg.spec.name
		        if (availablepgs == resource[:name])
					enabled = portg.computedPolicy.shapingPolicy.enabled
					Puppet.debug "existing portgroup ts enabled = #{enabled}"
					if (enabled == true) 
						return "Enabled"
					elsif (enabled == false)
						return "Disabled"
					end
        		end
  			end
       rescue Exception => excep
            Puppet.err excep.message
       end
 	end

  # Set the traffic shapping policy
	def traffic_shaping_policy=(value)
    	Puppet.debug "Updating the traffic shaping policy of given port group."
		begin
			traffic_shaping
    		return true
    	rescue Exception => excep
            Puppet.err excep.message
    	end
  end

  private

	def walk_dc(path=resource[:path])
		begin
	    @datacenter = walk(path, RbVmomi::VIM::Datacenter)
			if @datacenter.nil?
    			raise Puppet::Error, "No datacenter  in path: #{path}" unless @datacenter
			end
    		@datacenter
	    rescue Exception => excep
    		Puppet.err excep.message
	    end
	end

	def find_port_group
		Puppet.debug "Entering find_port_group"
		begin
        	@host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
			if @host.nil?
    			raise Puppet::Error, "No Host in datacenter #{walk_dc}" unless @host
			end
    	    @networksystem=@host.configManager.networkSystem
        	@pg = @networksystem.networkInfo.portgroup
	        for portg in (@pg) do
                availablepgs = portg.spec.name
                if (availablepgs == resource[:name])
                	return true
                end
        	end
        	#return false if portgroup not found
        	return false
	    rescue Exception => excep
    		Puppet.err excep.message
	    end
	end

	def traffic_shaping
        @host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
		if @host.nil?
    		raise Puppet::Error, "No Host in datacenter #{walk_dc}" unless @host
		end
        @networksystem=@host.configManager.networkSystem
        @pg = @networksystem.networkInfo.portgroup
        for portg in (@pg) do
            availablepgs = portg.spec.name
            if (availablepgs == resource[:name])
        		if ( resource[:traffic_shaping_policy] == :Enabled )
		            avgbandwidth = resource[:averagebandwidth].to_i * 1000	
        		    peakbandwidth =  resource[:peakbandwidth].to_i * 1000
		            burstsize = resource[:burstsize].to_i * 1024
        		    enabled = "true"
		            Puppet.debug "#{avgbandwidth},#{peakbandwidth},#{burstsize}"

        		    hostnetworktrafficshapingpolicy =  RbVmomi::VIM.HostNetworkTrafficShapingPolicy(:averageBandwidth => avgbandwidth, :burstSize => burstsize, :enabled => enabled, :peakBandwidth => peakbandwidth)

            		hostnetworkpolicy = RbVmomi::VIM.HostNetworkPolicy(:shapingPolicy => hostnetworktrafficshapingpolicy)
					if (find_vswitch == false)
						raise Puppet::Error, "Please provide valid vswitch"
					end	
    	            hostportgroupspec = RbVmomi::VIM.HostPortGroupSpec(:name => resource[:name], :policy => hostnetworkpolicy, :vlanId => resource[:vlanid], :vswitchName => resource[:vswitchname])
        	        @networksystem.UpdatePortGroup(:pgName => resource[:name], :portgrp => hostportgroupspec)

		        elsif ( resource[:traffic_shaping_policy] == :Disabled)
        		    hostnetworkpolicy = RbVmomi::VIM.HostNetworkPolicy()
					if (find_vswitch == false)
						raise Puppet::Error, "Please provide valid vswitch"
					end	
                	hostportgroupspec = RbVmomi::VIM.HostPortGroupSpec(:name => resource[:name], :policy => hostnetworkpolicy, :vlanId => resource[:vlanid], :vswitchName => resource[:vswitchname])
	                @networksystem.UpdatePortGroup(:pgName => resource[:name], :portgrp => hostportgroupspec)
            	end
        	end
        end
        return true
	end

  #find vswitch
  def find_vswitch
    host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
    networksystem=host.configManager.networkSystem
    vswitches = networksystem.networkInfo.vswitch

    for vswitch in (vswitches) do
      availablevswitch = vswitch.name
      if (availablevswitch == resource[:vswitchname])
        return true
      end
    end
    #return false if vswitch not found
    return false
  end

	def create_port_group
		Puppet.debug "Entering Create Port Group"
        	@host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
			if @host.nil?
    			raise Puppet::Error, "No Host in datacenter #{walk_dc}" unless @host
			end
        	@networksystem=@host.configManager.networkSystem
			if (find_vswitch == false)
				raise Puppet::Error, "Please provide valid vswitch"
			end	
	        hostnetworkpolicy = RbVmomi::VIM.HostNetworkPolicy()
        	hostportgroupspec = RbVmomi::VIM.HostPortGroupSpec(:name => name, :policy => hostnetworkpolicy, :vlanId => resource[:vlanid], :vswitchName => resource[:vswitchname])

	        @networksystem.AddPortGroup(:portgrp => hostportgroupspec)

			traffic_shaping
			if ( resource[:type] == "VMkernel" )
				Puppet.debug "Entering type VMkernel"
				if (resource[:ipconfig] == :manual)
					upip = RbVmomi::VIM.HostIpConfig(:dhcp => 0, :ipAddress => resource[:ipaddress], :subnetMask => resource[:subnetmask])
					hostvirtualnicspec =  RbVmomi::VIM.HostVirtualNicSpec(:ip => upip)
					@networksystem.AddVirtualNic(:portgroup => resource[:name], :nic => hostvirtualnicspec)	
				elsif (resource[:ipconfig] == :automatic)
					upip = RbVmomi::VIM.HostIpConfig(:dhcp => 1)
					hostvirtualnicspec =  RbVmomi::VIM.HostVirtualNicSpec(:ip => upip)
					@networksystem.AddVirtualNic(:portgroup => resource[:name], :nic => hostvirtualnicspec)	
				else
					upip = RbVmomi::VIM.HostIpConfig(:dhcp => 1)
					hostvirtualnicspec =  RbVmomi::VIM.HostVirtualNicSpec(:ip => upip)
					@networksystem.AddVirtualNic(:portgroup => resource[:name], :nic => hostvirtualnicspec)	
				end

				setupvmotion
			end
			Puppet.notice "Port Group Created"
	end

	def setupvmotion
		Puppet.debug "Inside setup vmotion"
		@host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
		if @host.nil?
    		raise Puppet::Error, "No Host in datacenter #{walk_dc}" unless @host
		end
		@networksystem=@host.configManager.networkSystem
    	@vmotionsystem = @host.configManager.vmotionSystem
	    vnics=@networksystem.networkInfo.vnic
	
		Puppet.debug resource[:vmotion]
		if (resource[:vmotion] == :true)
		  	for vnic in (vnics)
        		if (vnic.portgroup && resource[:name] == vnic.portgroup)
            		vnicdevice=vnic.device
        		end
    		end
      		@vmotionsystem.SelectVnic(:device => vnicdevice)
		end
		if (resource[:vmotion] == :false)
			Puppet.debug "setting vmotion flag to false"
			@vmotionsystem.DeselectVnic()
		end
	end

	def remove_port_group
        Puppet.debug "Inside remove_port_group"
        @host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
		if @host.nil?
    		raise Puppet::Error, "No Host in datacenter #{walk_dc}" unless @host
		end
        @networksystem=@host.configManager.networkSystem
        @networksystem.RemovePortGroup(:pgName => resource[:name])

        Puppet.notice "removed port group"
	end
end


