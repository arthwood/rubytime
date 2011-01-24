# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  before_filter :login_required, :only => :destroy
  
  def create
    s = params[:session]
    @login = s[:login]
    @password = s[:password]
    @remember_me = s[:remember_me] 
    
    user = User.find_by_login(@login)
    
    if user.present? && user.password == s[:password]
      reset_session
      self.current_user = user
      #new_cookie_flag = (@remember_me.to_i == 1)
      flash[:info] = 'Logged in successfully'
      
      redirect_back_or(root_url)
    else
      note_failed_signin
      
      render :action => :new
    end
  end
  
  def destroy
    flash[:info] = 'You have been logged out.'
    
    redirect_back_or(root_url)
  end
  
  protected
  
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{@login}'"
    logger.warn "Failed login for '#{@login}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
