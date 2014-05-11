require "bundler/capistrano"
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
require "capistrano/maintenance"
require 'thinking_sphinx/capistrano'
set :rvm_ruby_string, '1.9.3-p448'        # Or whatever env you want it to run in.
set :rvm_type, :system

load 'deploy/assets'
set :user, "deployer"
set :runner, "buffpojken"
set :scm, :git
set :repository, "git@github.com:monkeydancers/the-creator.git"   
set :branch, "master"  
set :deploy_to, "/sites/creator3"
set :rails_env, "production"
set :domain, "31.192.226.219"     
set :application, 'creator3'    

role :app, domain
role :web, domain
role :db, domain, :primary => true

default_run_options[:pty] = true

ssh_options[:forward_agent] = true

set :use_sudo, false

before "deploy:update", "god:terminate_if_running"
after "deploy:update", "npm:install"
after "deploy:symlink", "god:start"   

namespace :deploy do 
  task :activate_sphinx, :roles => [:app] do
    symlink_sphinx_indexes
    thinking_sphinx.configure
    thinking_sphinx.start
  end

  desc "Link up Sphinx's indexes."
  task :symlink_sphinx_indexes, :roles => [:app] do
    run "ln -nfs #{shared_path}/db/sphinx /sites/creator3/current/db/sphinx"
  end
end

before 'deploy:update_code', 'thinking_sphinx:stop'
after 'deploy:symlink', 'deploy:activate_sphinx'

namespace :god do
  def god_is_running
    !capture("#{god_command} status >/dev/null 2>/dev/null || echo 'not running'").start_with?('not running')
  end

  def god_command
    "cd #{current_path}; bundle exec god"
  end

  desc "Stop god"
  task :terminate_if_running do
    if god_is_running
      run "#{god_command} terminate"
    end
  end

  desc "Start god"
  task :start do
    god_config_path = File.join(current_path, 'config', "#{rails_env}.god")
    environment = { :RAILS_ENV => rails_env, :RAILS_ROOT => current_path }
    run "#{god_command} -c #{god_config_path}", :env => environment
  end
end

namespace :npm do 
  task :install do 
    run "cd #{current_path}/node; /usr/bin/npm install"
  end
end

namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "cd #{current_path}; bundle exec thin -C /sites/creator3/shared/conf/thin.yml start"
  end
  task :stop, :roles => [:web, :app] do
    run "cd #{current_path}; bundle exec thin -C /sites/creator3/shared/conf/thin.yml stop"
  end
  task :restart, :roles => [:web, :app] do
    run "cd #{current_path}; bundle exec thin -C /sites/creator3/shared/conf/thin.yml restart"
  end
end
