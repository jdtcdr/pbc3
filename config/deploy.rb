# RVM bootstrap
###$:.unshift(File.expand_path("~/.rvm/lib"))
require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.2-p180'
set :rvm_type, :system

# bundler bootstrap
require 'bundler/capistrano'

set :application, "pbc3"

role :web, "linode1.pbc.org"                          # Your HTTP server, Apache/etc
role :app, "linode1.pbc.org"                          # This may be the same as your `Web` server
role :db,  "linode1.pbc.org", :primary => true # This is where Rails migrations will run
#role :web, "test.pbc.org"                          # Your HTTP server, Apache/etc
#role :app, "test.pbc.org"                          # This may be the same as your `Web` server
#role :db,  "test.pbc.org", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

#server
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :deploy_to, "/srv/rails/#{application}"
set :user, "webapp"
#set :user, "webapp3"
set :group, "webapp"
set :use_sudo, false

# repository
set :scm, :git
set :repository,  "git@github.com:ericsoderberg/pbc3.git"
set :deploy_via, :remote_cache
set :branch, "master"
set :git_shallow_clone, 1
set :git_enable_submodules, 1

# tasks
namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  #desc "Symlink shared resources on each release - not used"
  #task :symlink_shared, :roles => :app do
  #  #run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  #end
end

# http://www.hackido.com/2010/03/capistrano-sunspot-in-rails.html
task :before_update_code do
  #stop solr:
  #run "cd #{current_path} && rake sunspot:solr:stop RAILS_ENV=production"
end

#after "deploy:update_crontab", "deploy:solr:symlink"

#namespace :solr do
#  desc <<-DESC
#    Symlink in-progress deployment to a shared Solr index.
#    DESC
#  task :symlink, :except => { :no_release => true } do
#    run "ln -nfs #{shared_path}/solr/data #{current_path}/solr/data"
#    run "ls -al #{current_path}/solr/pids/"
#    run "cd #{current_path} && rake sunspot:solr:start RAILS_ENV=production"
#  end
#end

#after 'deploy:update_code', 'deploy:symlink_shared'

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end