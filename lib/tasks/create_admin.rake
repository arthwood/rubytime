require 'config/environment'

namespace :db do
  desc 'Creates admin account'
  task :create_admin do
    user = User.new(:login => 'admin', :name => 'Artur Bilski', :email => 'artur.bilski@llp.pl', 
      :password => 'asdf1234', :password_confirmation => 'asdf1234')
    user.active = true
    user.admin = true
    user.save
  end
end
