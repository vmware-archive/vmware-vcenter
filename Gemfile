source 'https://rubygems.org'

gem 'hashdiff'
gem 'rbvmomi', '2.0.1'
gem 'net-ssh'
gem 'dell-asm-util', :git => 'https://github.com/dell-asm/dell-asm-util.git', :branch => 'master'

group :development, :test do
  gem 'rake'
  gem 'rspec', :require => false
  gem 'mocha', :require => false
  gem 'puppetlabs_spec_helper', :require => false
  gem 'rspec-puppet', :require => false
  gem 'puppet-lint', :require => false
end

facterversion = ENV['GEM_FACTER_VERSION']
if facterversion
    gem 'facter', facterversion
else
    gem 'facter', :require => false
end

ENV['GEM_PUPPET_VERSION'] ||= ENV['PUPPET_GEM_VERSION']
if puppetversion = ENV['GEM_PUPPET_VERSION']
  gem 'puppet', puppetversion
else
  gem 'puppet', :require => false
end
