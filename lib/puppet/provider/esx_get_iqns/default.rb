# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_get_iqns).provide(:esx_get_iqns, :parent => Puppet::Provider::Vcenter) do
  @doc = "Get availavle iqns from esx host."
  def get_esx_iqns
    begin
      iqnlist = Array.new
      hbalist = get_iqn_from_host
      if !hbalist.nil?
        iqnlist = get_iqn(hbalist)
      else
        raise Puppet::Error, "Could not find any IQNS from given host server"
      end
      if iqnlist.size > 0
        Puppet.notice "Successfully found iqns from host: #{resource[:host]}"
      else
        Puppet.err "Unable to find iqns from host: #{resource[:host]}  "
      end
      return iqnlist
    rescue Exception => excep
      Puppet.err "Unable to perform the operation because the following exception occurred - "
      Puppet.err excep.message
    end

  end

  def get_esx_iqns=(value)
    Puppet.notice "get_esx_iqns:#{value}"
  end

  def get_iqn_from_host
    begin
      hbalist = Array.new
      servers = nil
      command = "/usr/bin/esxcli --server=#{resource[:host]} --username=#{resource[:hostusername]}  --password=#{resource[:hostpassword]} iscsi adapter list"
      IO.popen(command) do |servers|
        servers.each do |hbas|
          if !(hbas.include? "unbound") and !(hbas.include? "-------") and !(hbas.include? "Description")
            hbalist.push hbas.split[0]
          end
        end
      end
      return hbalist
    rescue Exception => excep
      puts excep.message
      return nil
    end
  end

  def get_iqn( hbalist)
    iqns = Array.new
    hbalist.each do |hba|
      newcommand = "/usr/bin/esxcli --server=#{resource[:host]} --username=#{resource[:hostusername]}  --password=#{resource[:hostpassword]} iscsi adapter get -A  #{hba}"
      IO.popen(newcommand) do |server|
        server.each do |iqn|
          puts iqn
          if iqn.include? "Name:" and !(iqn.include? "Driver Name:")
            matchdata = iqn.match(/([^>]*): ([^>]*)/)
            iqns.push matchdata[2]
          end
        end
      end
    end
    return iqns
  end

  def create
  end

  def destroy
  end

  def exists?
    return true
  end
end