class UsersController < ApplicationController
  before_filter :admin_required, :except => [:request_password, :do_request_password, :reset]
  
  def index
    set_new_user
    set_list_data
  end
  
  def new
    set_new_user
    
    render :partial => 'form'
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
      set_new_user
      set_list_data
      
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
    data.delete(:group)
    
    @user.client = nil if data[:client_id].blank?
    @user.role = nil if data[:role_id].blank?
    
    @success = @user.update_attributes(data) 
    
    if @success
      flash[:info] = 'Succesfully updated User!'
      redirect_to users_url
    else
      flash.now[:error] = "User couldn't be updated"
      
      set_list_data
      
      render :action => :index
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    
    partial, collection = if @user.employee?
      ['employees', User.employees.not_admins]
    else
      ['clients_users', User.clients.not_admins]
    end
    
    render :json => {
      :html => render_to_string(:partial => partial, :object => collection, :as => :collection), 
      :success => true
    } 
  end
  
  def do_request_password
    data = params[:reset_password]
    email = data[:email]
    @user = User.find_by_email(email)
    
    if @user.nil?
      flash[:error] = "I could not find a user with the email address '#{email}'. Did you type it correctly?"
    else
      @user.create_login_key
      UserMailer.reset(@user).deliver
      flash[:info] = 'Password reset email sent.'
    end
    
    redirect_to login_url
  end
  
  def reset
    @key = params[:key]
    @user = User.find_by_login_key(@key)
    
    if @user
      @user.clear_login_key
      self.current_user = @user
      redirect_to root_url
    else
      flash[:error] = "Provided key in the URL is wrong: #{@key}"
      redirect_to login_url
    end
  end
  
  private
  
  def set_new_user
    @user = User.new
  end
  
  def set_list_data
    @admins = User.admins
    @employees = User.employees.not_admins
    @clients_users = User.clients.not_admins
  end
end
