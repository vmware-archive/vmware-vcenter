provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:iscsi_intiator_binding).provide(:iscsi_intiator_binding, :parent => Puppet::Provider::Vcenter) do
  @doc = "Binding the HBA to VMkernel nic."
  def create
    #Binding the HBA to VMkernel nic.

    Puppet.notice "Binding the HBA to VMkernel nic."

    vmk_nics = resource[:vmknics]

    vmk_nic_arr = vmk_nics.split(' ')

    for each_vmk_nic in vmk_nic_arr
      begin
        cmd = "#{resource[:script_executable_path]} --username #{resource[:host_username]} --password #{resource[:host_password ]} --server=#{resource[:host_name]} iscsi networkportal add --nic #{each_vmk_nic} --adapter #{resource[:vmhba]}"

        error_log_filename = "/tmp/bindVMkernel_err_log.#{Process.pid}"
        log_filename = "/tmp/bindVMkernel_log.#{Process.pid}"

        flag = execute_system_cmd(cmd , log_filename , error_log_filename)

      rescue Exception => exc
        flag = 1
        Puppet.err(exc.message)
      end
      if flag.eql?(0)
        Puppet.notice "HBA '#{resource[:vmhba]}' is bind to VMkernel nic '#{each_vmk_nic}'."
      else
        Puppet.err "Unable to bind HBA '#{resource[:vmhba]}' to VMkernel nic '#{each_vmk_nic}'."
      end
    end
  end

  def destroy
    #Unbind the HBA to VM kernal nic.
    Puppet.notice "Unbind the HBA to VMkernel nic."

    vmk_niks = resource[:vmknics]

    vmk_nik_arr = vmk_niks.split(' ')

    for each_vmk_nic in vmk_nik_arr
      begin
        cmd = "#{resource[:script_executable_path]} --username #{resource[:host_username]} --password #{resource[:host_password ]} --server=#{resource[:host_name]} iscsi networkportal remove --nic #{each_vmk_nic} --adapter #{resource[:vmhba]}"

        error_log_filename = "/tmp/bindVMkernel_err_log.#{Process.pid}"
        log_filename = "/tmp/bindVMkernel_log.#{Process.pid}"

        flag = execute_system_cmd(cmd , log_filename , error_log_filename)

      rescue Exception => exc
        flag = 1
        Puppet.err(exc.message)
      end
      if flag.eql?(0)
        Puppet.notice "HBA '#{resource[:vmhba]}' is unbind from VMkernel nic '#{each_vmk_nic}'."
      else
        Puppet.err "Unable to unbind HBA '#{resource[:vmhba]}' from VMkernel nic '#{each_vmk_nic}'."
      end
    end
  end

  # Check whether HBA is mapped to VMkernel nic.
  def exists?
    is_binded
  end

  def is_binded
    flag = 0

    cmd = "#{resource[:script_executable_path]} --username #{resource[:host_username]} --password #{resource[:host_password ]} --server=#{resource[:host_name ]} iscsi networkportal list -A #{resource[:vmhba]}"

    error_log_filename = "/tmp/bind_rerr_log.#{Process.pid}"
    log_filename = "/tmp/bind_log.#{Process.pid}"

    system(cmd , :out => [log_filename, 'a'], :err => [error_log_filename, 'a'])
    if $? != 0
      flag = 1
      err_content = File.open(error_log_filename, 'rb') { |file| file.read }
      Puppet.err err_content
    else
      content = File.open(log_filename, 'rb') { |file| file.read }
      if (/(?i:Vmknic:\s+)/.match(content))
        actual_binded_vmk_nics_arr = content.scan(/Vmknic:\s+(?<match>.*)/) # It will be array of Array. Example: actual_binded_vmk_nics_arr : [["vmk1"], ["vmk2"]]
        Puppet.notice "Actual binded VMKernel nic : #{actual_binded_vmk_nics_arr}"

        binded_vmk_nics_arr = []
        for item in actual_binded_vmk_nics_arr
          binded_vmk_nics_arr.push(item[0])
        end

        Puppet.notice "Binded VMKernel nic : #{binded_vmk_nics_arr}" # Binded VMKernel nic : [["vmk1"], ["vmk2"]]

        input_vmk_nics = resource[:vmknics]
        Puppet.notice "Input VMKernel nic : #{input_vmk_nics}"

        input_vmk_nics_arr = input_vmk_nics.split(' ')
        Puppet.notice "input_vmk_nics_arr : #{input_vmk_nics_arr}"
        Puppet.notice "binded_vmk_nics_arr : #{binded_vmk_nics_arr}"

        if ( binded_vmk_nics_arr.uniq.sort == input_vmk_nics_arr.uniq.sort )
          flag = 0
        else
          flag = 1
        end
      else
        flag = 1
      end
    end

    remove_files( error_log_filename , log_filename)

    if flag.eql?(0)
      Puppet.info "HBA is already bind to VMkernel."
      return true
    else
      Puppet.notice "HBA is not bind to VMKernel"
      return false
    end
  end

  private

  def execute_system_cmd(cmd,log_filename,error_log_filename)
    flag = 0
    system(cmd , :out => [log_filename, 'a'], :err => [error_log_filename, 'a'])
    if $? != 0
      flag = 1
      err_content = File.open(error_log_filename, 'rb') { |file| file.read }
      Puppet.err err_content
    else
      content = File.open(log_filename, 'rb') { |file| file.read }
      if (/(?i:Error|failed|SOAP|Enter maintenance mode|Could not find requested datastore|called at|pm line|does not exist|Could not bind)/.match(content))
        # got some error
        Puppet.err content
        flag = 1
      else
        Puppet.notice content
      end
    end
    remove_files(log_filename, error_log_filename)
    return flag
  end

  # Removing files
  def remove_files(logfile , errorfile)
    if File.exist?(logfile)
      File.delete(logfile)
    end

    if File.exist?(errorfile)
      File.delete(errorfile)
    end
  end
end