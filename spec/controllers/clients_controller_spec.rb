require 'spec_helper'

include SharedMethods

describe ClientsController do
  include RubytimeHelper
  
  shared_examples_for "index redirection" do
    it "should redirect to :index" do
      response.should be_redirect
      response.should redirect_to(clients_path)
    end
  end
  
  shared_examples_for "new client" do
    it "should set @client variable" do
      var = assigns(:client)
      var.should be_an_instance_of(Client)
      var.should be_new_record
    end
  end
  
  shared_examples_for "list data" do
    it "should set @clients variable" do
      var = assigns(:clients)
      var.should be_an_instance_of(Array)
    end
  end
  
  describe "index" do
    before do
      login_as_admin
      get :index
    end
    
    it "should set @user variable" do
      var = assigns(:user)
      var.should be_an_instance_of(User)
      var.should be_new_record
    end
    
    it_should_behave_like "render index"
    it_should_behave_like "new client"
    it_should_behave_like "list data"
  end
  
  describe "new" do
    before do
      login_as_admin
      get :new
    end
    
    it_should_behave_like "new client"
    it_should_behave_like "render form"
  end
  
  describe "create" do
    let!(:user_count) { User.count }
    let!(:client_count) { Client.count }

    
    before { login_as_admin }
    
    context "with valid data" do
      before do
        get :create, :client => {
          :name => 'Microsoft', 
          :email => 'bill@microsoft.com', 
          :description => 'Potential client :)',
          :active => 1
        }, :user => {
          :name => 'Rick', 
          :login => 'rick', 
          :email => 'rick@email.com', 
          :password => 'secret123', 
          :password_confirmation => 'secret123', 
          :active => 1
        }
      end
      
      it "should render create client" do
        Client.count.should eql(client_count + 1)
      end
      
      it "should render create user" do
        User.count.should eql(user_count + 1)
      end
      
      it "should assign this user to client" do
        assigns(:user).client.should eql(assigns(:client))
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "index redirection"
    end
    
    context "with invalid data" do
      before do
        get :create, :client => {}, :user => {}
      end
      
      it_should_behave_like "flash error"
      it_should_behave_like "render index"
      it_should_behave_like "new client"
      it_should_behave_like "list data"
    end
  end
end
