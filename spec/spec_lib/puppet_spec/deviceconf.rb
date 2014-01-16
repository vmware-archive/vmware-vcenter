module PuppetSpec::Deviceconf
  def my_deviceurl(my_module, name)
	dir = File.expand_path(File.dirname(__FILE__))
	dirarray = dir.split(File::SEPARATOR)
	dirarray.shift

	dirsource = ''
	for sdir in dirarray
	  if sdir == my_module then
					break
	  end
			sdir = '/'+sdir
			dirsource = dirsource + sdir
	end
	my_fixture_dir = dirsource+'/'+my_module+'/spec/fixtures/device'

    file = File.join(my_fixture_dir, name)
    unless File.readable? file then
      fail Puppet::DevError, "fixture '#{name}' for #{my_fixture_dir} is not readable"
    end
    return file
  end

end
