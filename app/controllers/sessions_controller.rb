# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  before_filter :login_required, :only => :destroy
  
  def create
    s = params[:session]
    @login = s[:login]
    @user = User.find_by_login(@login)
    
    if @user.present?
      if @user.password == s[:password]
        redirect_back_or(root_url)
        reset_session
        self.current_user = @user
        flash[:info] = 'Logged in successfully'
      else
        note_failed_signin('Invalid password')
        
        render :action => :new
      end
    else
      note_failed_signin("There's no user '#{@login}'")
      
      render :action => :new
    end
  end
  
  def destroy
    reset_session
    flash[:info] = 'You have been logged out.'
    redirect_back_or(root_url)
  end
  
  protected
  
  # Track failed login attempts
  def note_failed_signin(message)
    flash[:error] = message
    logger.warn "Failed login for '#{@login}' from #{request.remote_ip} at #{Time.now.utc} (#{message})"
  end
end
