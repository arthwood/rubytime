set :application, 'rubytime.arthwood.com'
set :repository,  'git@github.com:arthwood/RubyTime.git'
set :deploy_to, '/home/arthwood/www/rubytime'
set :rails_env, 'production'
set :deploy_via, :remote_cache
set :keep_releases, 3
set :use_sudo, false
set :scm, :git
set :git_enable_submodules, true

server "arthwood@rubytime.arthwood.com", :app, :web, :db, :primary => true

after "deploy:update_code", "deploy:link_configuration_files"
after "deploy:update_code", "deploy:bundle"

namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "restart-app rubytime"
  end
  
  desc "Links configuration files"
  task :link_configuration_files do
    %w(database.yml).each do |i|
      run "cd #{File.join(release_path, 'config')} && ln -s #{File.join(shared_path, 'config', i)}"
    end
  end
  
  desc "Install bundler gems"
  task :bundle do
    run "cd #{release_path}; bundle install"
  end
end
