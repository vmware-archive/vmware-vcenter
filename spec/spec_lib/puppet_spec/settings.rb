module PuppetSpec::Settings

  TEST_APP_DEFAULT_DEFINITIONS = {
    :name         => { :default => "test", :desc => "name" },
    :logdir       => { :type => :directory, :default => "test", :desc => "logdir" },
    :confdir      => { :type => :directory, :default => "test", :desc => "confdir" },
    :vardir       => { :type => :directory, :default => "test", :desc => "vardir" },
    :rundir       => { :type => :directory, :default => "test", :desc => "rundir" },
  }
  
end
