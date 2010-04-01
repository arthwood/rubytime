require 'config/environment'

namespace :db do
  desc 'Creates roles'
  task :create_roles do
    Role.create([
      {:name => 'developer', :can_manage_financial_data => false},
      {:name => 'project manager', :can_manage_financial_data => true},
      {:name => 'tester', :can_manage_financial_data => false}
    ])
  end
end
