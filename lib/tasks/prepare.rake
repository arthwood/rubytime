namespace :db do
  desc 'Populates tables with initial data'
  task :prepare => :environment do
    @roles = Role.create([
      {:name => 'developer', :can_manage_financial_data => false},
      {:name => 'project manager', :can_manage_financial_data => true},
      {:name => 'tester', :can_manage_financial_data => false}
    ])
    
    @user = User.new(:login => 'admin', :name => 'Artur Bilski', :email => 'artur.bilski@llp.pl', :role_id => 2)
    @user.password = CONFIG[:admin][:password]
    @user.active = true
    @user.admin = true
    @user.save
  end
end
