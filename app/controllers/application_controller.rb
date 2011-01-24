class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include RubytimeHelper
  
  before_filter :init_activity
  
  protected
  
  def init_activity
    @activity = Activity.new
  end
  
  def redirect_back_or(default, options = {})
    redirect_to(session[:return_to] || params[:return_to] || default)
    
    session[:return_to] = nil
  end
  
  def store_location(url = nil)
    session[:return_to] = url || request.referer
  end
  
  def login_required
    unauthorized unless logged_in?
  end
  
  def admin_required
    unauthorized unless logged_in? && current_user.admin?
  end
  
  def unauthorized(path = root_path)
    flash[:notice] = 'You need to sign in to perform this action.'
    
    redirect_to(path)
  end
  
  def clear_session
    session.delete(:user_id)
  end
end
