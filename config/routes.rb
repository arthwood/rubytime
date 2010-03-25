ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => :sessions, :action => :destroy
  map.login '/login', :controller => :sessions, :action => :new
  map.register '/register', :controller => :users, :action => :create
  map.signup '/signup', :controller => :users, :action => :new
  map.reset '/reset/:key', :controller => :users, :action => :reset
  
  map.resources :users, :collection => {:request_password => :get, :do_request_password => :post}

  map.resource :sessions

  map.resources :activities

  map.root :controller => :activities

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
