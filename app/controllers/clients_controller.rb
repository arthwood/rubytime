class ClientsController < ApplicationController
  def index
    @clients = Client.all
  end
  
  def create
    client = params[:client]
    @user = ClientUser.new(client.delete(:user))
    @client = Client.new(client)
    @client.users << @user
    
    @success = @client.save
    
    if @success
      redirect_to clients_url
    else
      @clients = Client.all
      
      render :action => :index
    end
  end
end
