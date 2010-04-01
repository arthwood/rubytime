class UsersController < ApplicationController
  def index
    @users = User.all
    @employees, @clients_users = @users.partition {|i| i.client.nil?}
  end
  
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])

    success = @user && @user.save

    if success && @user.errors.empty?
      
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end
  
  def do_request_password
    data = params[:reset_password]
    email = data[:email]
    @user = User.find_by_email(email)
    
    if @user.nil?
      flash[:error] = "I could not find a user with the email address '#{email}'. Did you type it correctly?"
      
      redirect_to login_url
    else
      @user.reset_login_key!
      UserMailer.deliver_reset(@user)
      flash[:notice] =  'Password reset email sent.'
    end
  end
  
  def reset
    @key = params[:key]
    @user = User.find_by_login_key(@key)
    
    if @user
      self.current_user = @user
      redirect_to root_url
    else
      flash[:notice] = "Provided key in the URL is wrong: #{@key}"
      redirect_to login_url
    end
  end
end
