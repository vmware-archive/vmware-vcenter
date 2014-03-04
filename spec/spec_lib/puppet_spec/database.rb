def sqlite?
  if $sqlite.nil?
    begin
      require 'sqlite3'
      $sqlite = true
    rescue LoadError
      $sqlite = false
    end
  end
  $sqlite
end

def can_use_scratch_database?
  sqlite? and Puppet.features.rails?
end

def setup_scratch_database
  Puppet[:dbadapter] = 'sqlite3'
  Puppet[:dblocation] = ':memory:'
  Puppet[:railslog] = PuppetSpec::Files.tmpfile('storeconfigs.log')
  Puppet::Rails.init
end
