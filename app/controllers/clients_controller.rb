class ClientsController < ApplicationController
  def index
    @clients = Client.all
    @client = Client.new
    @user = User.new
  end
  
  def create
    @client = Client.new(params[:client])
    @user = User.new(params[:user])
    @client.users << @user
    
    @success = @client.save
    
    if @success
      flash[:info] = 'Succesfully created Client and its User!'
      redirect_to clients_url
    else
      flash.now[:error] = "Client and its User couldn't be created"
      
      @clients = Client.all
      
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
      flash.now[:error] = "Client couldn't be updated"
      
      @clients = Client.all
      
      render :action => :index
    end
  end
  
  def destroy
    @client = Client.find(params[:id])
    @client.destroy
    
    @clients = Client.all
    
    render :partial => 'listing' 
  end
end
