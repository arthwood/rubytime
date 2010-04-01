class ClientsController < ApplicationController
  def index
    @clients = Client.all
    @client = Client.new(:active => true)
  end
  
  def create
    @client = Client.new(params[:client])
    @user = ClientUser.new(params[:user])
    @client.users << @user
    
    @success = @client.save
    
    if @success
      flash[:info] = 'Succesfully created Client and its User!'
      redirect_to clients_url
    else
      flash[:error] = "Client and its User couldn't be created"
      
      @clients = Client.all
      
      render :action => :index
    end
  end
end
