source 'http://rubygems.org'

gem 'rails', '3.2.10'
gem 'haml'
gem 'mysql2', '0.3.11'
gem 'prawn'
gem 'fastercsv'
gem 'bcrypt-ruby', :require => 'bcrypt'

group :development, :test do
  gem 'rspec', :require => nil
  gem 'rspec-rails', :require => nil
end

group :development do
  gem 'eventmachine', '1.0.0'
  gem 'thin'
  gem 'capistrano', :require => nil
  gem 'capistrano-ext', :require => nil
end

group :test do
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'spork-rails'
end

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'execjs'
  gem 'libv8', :platform => :ruby
  gem 'therubyracer', :platforms => :ruby
end
