name         'vmware-vcenter'
source       'git@github.com:puppetlabs/vmware-vcenter.git'
author       'Puppet Labs | VMware 2013'
license      'Apache 2.0'
summary      'VMware vCenter puppet module'
description  'VMware vCenter resource management.'
project_page 'https://github.com/puppetlabs/vmware-vcenter'

moduledir = File.dirname(__FILE__)
ENV['GIT_DIR'] = moduledir + '/.git'

git_version = %x{git describe --dirty --tags}.chomp.sub(/\.([0-9]+)-/) {|v| ".#{v[1..-2].to_i(10) + 1}-" }
unless $?.success? and git_version =~ /^\d+\.\d+\.\d+/
  raise "Unable to determine version using git: #{$?} => #{git_version.inspect}"
end
version    git_version

## Add dependencies, if any:
dependency 'puppetlabs/stdlib', '>= 2.0.0'
dependency 'vmware/vmware_lib', '>= 0.0.1'
dependency 'puppetlabs/pe_gem', '>= 0.0.1'
dependency 'nanliu/staging', '>= 0.2.1'
