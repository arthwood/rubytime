class ClientsController < ApplicationController
  before_filter :admin_required
  
  def index
    set_list
    set_new
    @user = User.new
  end
  
  def new
    set_new
    
    render :partial => 'form'
  end
  
  def create
    @client = Client.new(params[:client])
    @user = User.new(params[:user].merge(:admin => false))
    @client.users << @user
    
    @success = @client.save
    
    if @success
      flash[:info] = 'Succesfully created Client and its User!'
      redirect_to clients_url
    else
      flash.now[:error] = "Client and its User couldn't be created"
      set_list
      
      render :action => :index
    end
  end
  
  def edit
    @client = Client.find(params[:id])
    @user = @client.users.first 
    
    render :partial => 'form'
  end
  
  def update
    @client = Client.find(params[:id])
    @user = @client.users.first
    
    @success = @user.update_attributes(params[:user]) && @client.update_attributes(params[:client]) 
    
    if @success
      flash[:info] = 'Succesfully updated Client!'
      redirect_to clients_url
    else
      flash.now[:error] = [].tap do |i|
        i << "Client couldn't be updated." unless @client.valid?
        i << "User couldn't be updated." unless @user.valid?
      end.join(' ')
      
      set_list
      
      render :action => :index
    end
  end
  
  def destroy
    @client = Client.find(params[:id])
    @client.destroy
    
    set_list
    
    render :json => {:html => render_to_string(:partial => 'listing'), :success => true} 
  end
  
  private
  
  def set_new
    @client = Client.new
  end
  
  def set_list
    @clients = Client.all
  end
end
