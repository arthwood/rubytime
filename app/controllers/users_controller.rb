class UsersController < ApplicationController
  def index
    @user = User.new
    @users = User.all(:order => :name)
    @employees, @clients_users = @users.partition {|i| i.employee?}
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
      flash.now[:error] = "User couldn't be created"
      @users = User.all
      @employees, @clients_users = @users.partition {|i| i.employee?}
      
      render :action => :index
    end
  end
  
  def edit
    @user = User.find(params[:id])
    
    render :partial => 'form'
  end
  
  def update
    @user = User.find(params[:id])
    
    data = params[:user]
    
    @user.client = nil if data[:client_id].blank?
    @user.role = nil if data[:role_id].blank?
    
    @success = @user.update_attributes(data) 
    
    if @success
      flash[:info] = 'Succesfully updated User!'
      redirect_to users_url
    else
      flash.now[:error] = "User couldn't be updated"
      
      @users = User.all
      @employees, @clients_users = @users.partition {|i| i.employee?}
      
      render :action => :index
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    @users = User.all
    
    render :partial => @user.employee? ? 'listing_employees' : 'listing_clients_users'
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
