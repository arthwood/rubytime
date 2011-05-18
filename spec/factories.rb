FactoryGirl.define do
  sequence :user_name do |n|
    "User #{n}"
  end
  
  sequence :login do |n|
    "login#{n}"
  end
  
  sequence :email do |n|
    "user#{n}@email.com"
  end
  
  sequence :client_name do |n|
    "client#{n}"
  end
  
  sequence :project_name do |n|
    "project#{n}"
  end
  
  factory :developer, :class => :role do
    id 1
    name "developer"
    can_manage_financial_data false
  end
  
  factory :manager, :class => :role do
    id 2
    name "manager"
    can_manage_financial_data true
  end
  
  factory :client do
    name { Factory(:client_name) } 
    email { "user@#{name}.com" }
    active true
  end
  
  factory :user do
    name { Factory(:user_name) }
    login { Factory(:login) }
    email
    password "asdf1234"
    password_confirmation "asdf1234"
    active true
    role_id 1
    admin false
  end
  
  factory :admin, :parent => :user do
    admin true
  end
  
  factory :client_user, :parent => :user do
    client
  end
  
  factory :project do
    name { Factory(:project_name) } 
    client
    active true
  end
  
  factory :invoice do
    name "April 2011"
    user
    client
    issued_at 2.days.ago.to_date
  end
  
  factory :activity do
    comments "working on Graphy GEM"
    date 1.week.ago.to_date
    minutes 435
    project
    user
  end
  
  factory :invoiced_activity, :parent => :activity do
    invoice
    invoiced_at 1.day.ago.to_date
    value 40
    currency_id 1
  end
  
  factory :pound, :class => :currency do
    id 1
    name "pound"
    plural "pounds"
    symbol "p"
    prefix true
  end
  
  factory :dollar, :class => :currency do
    id 2
    name "dollar"
    plural "dollars"
    symbol "$"
    prefix true
  end
  
  factory :hourly_rate do
    project
    role_id 1
    date 2.weeks.ago.to_date
    value 40.00
    currency_id 1
  end
  
  factory :free_day do
    user
    date 1.day.ago.to_date
  end
end
