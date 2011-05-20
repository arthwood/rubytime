class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include RubytimeHelper
  
  before_filter :init_activity
  
  protected
  
  def init_activity
    @activity = Activity.new
  end
  
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    
    session[:return_to] = nil
  end
  
  def store_location
    session[:return_to] = request.referer
  end
  
  def login_required
    unauthorized unless logged_in?
  end
  
  def admin_required
    unauthorized unless logged_in? && current_user.admin?
  end
  
  def editor_required
    unauthorized unless logged_in? && current_user.editor?
  end
  
  def unauthorized(path = root_path)
    flash[:error] = 'You need to sign in to perform this action.'
    
    store_location
    
    redirect_to(path)
  end
end
