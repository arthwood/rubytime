# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  before_filter :login_required, :only => :destroy
  
  def create
    s = params[:session]
    @login = s[:login]
    @password = s[:password]
    @remember_me = s[:remember_me] 
    logout_keeping_session!
    user = User.authenticate(@login, @password)
    
    if user
      reset_session
      self.current_user = user
      new_cookie_flag = (@remember_me.to_i == 1)
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default(root_url)
      flash[:info] = 'Logged in successfully'
    else
      note_failed_signin
      render :action => :new
    end
  end

  def destroy
    logout_killing_session!
    flash[:info] = 'You have been logged out.'
    redirect_back_or_default(root_url)
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{@login}'"
    logger.warn "Failed login for '#{@login}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
