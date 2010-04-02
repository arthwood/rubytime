class UsersController < ApplicationController
  def index
    @user = User.new(:active => true)
    @users = User.all
    @employees, @clients_users = @users.partition {|i| i.client.nil?}
  end
  
  def create
    data = params[:user]
    data.delete(:group)
    
    @user = User.new(data)
    
    success = @user.save
    
    if success
      flash[:info] = "User successfully created!"
      
      redirect_to users_url
    else
      flash[:error] = "User couldn't be created"
      index
      render :action => :index
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
