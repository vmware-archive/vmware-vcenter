provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:iscsi_intiator_binding).provide(:iscsi_intiator_binding, :parent => Puppet::Provider::Vcenter) do
  @doc = "Binding the HBA to VMkernel nic."
  
  def create
    #Binding the HBA to VMkernel nic.
    
      Puppet.notice "Binding the HBA to VMkernel nic."

	  vmk_niks = resource[:vmknics]
	  
	  vmk_nik_arr = vmk_niks.split(' ')
	  
	  for each_vmk_nic in vmk_nik_arr
		begin
	    cmd = "#{resource[:script_executable_path]} --username #{resource[:host_username]} --password #{resource[:host_password ]} --server=#{resource[:name ]} iscsi networkportal add --nic #{each_vmk_nic} --adapter #{resource[:vmhba]}"

	    puts cmd 
	  
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

  # Check whether HBA is mapped to VMkernel nic.
  def exists?
    false
  end
  
  def execute_system_cmd(cmd,log_filename,error_log_filename)
    flag = 0
    ENV['PERL_LWP_SSL_VERIFY_HOSTNAME']= '0' ;
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
  
  private
end