require 'spec_helper'

include SharedMethods

describe ClientsController do
  before { login_as(:admin) }
  
  describe "index" do
    let!(:client) { Factory(:client) }
    
    before do
      get :index
    end
    
    it_should_behave_like "new resource", :client
    it_should_behave_like "new resource", :user
    it_should_behave_like "render template", :index
    it_should_behave_like "list of", :clients, [:client]
  end
  
  describe "new" do
    before do
      get :new
    end
    
    it_should_behave_like "new resource", :client
    it_should_behave_like "render template", :form
  end
  
  describe "create" do
    let!(:admin) { Factory(:admin) }
    let!(:user_count) { User.count }
    let!(:client_count) { Client.count }
    
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
      
      it "should create client" do
        Client.count.should eql(client_count + 1)
      end
      
      it "should create user" do
        User.count.should eql(user_count + 1)
      end
      
      it "should assign this user to client" do
        assigns(:user).client.should eql(assigns(:client))
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "redirection", :clients
    end
    
    context "with invalid data" do
      before do
        get :create, :client => {}, :user => {}
      end
      
      it "should not create client" do
        Client.count.should eql(client_count)
      end
      
      it "should not create user" do
        User.count.should eql(user_count)
      end
      
      it_should_behave_like "flash error"
      it_should_behave_like "render template", :index
      it_should_behave_like "new resource", :client
      it_should_behave_like "list of", :clients
    end
  end
  
  describe "edit" do
    let!(:client) { Factory(:client) }
    
    before do
      get :edit, :id => client.id
    end
    
    it_should_behave_like "render template", :form
    it_should_behave_like "variable", :client
  end
  
  describe "update" do
    let!(:client) { Factory(:client) }
    let!(:user) { Factory(:user, :client => client) }
    
    context "with valid data" do
      let(:client_name) { 'Mike' }
      let(:user_name) { 'John' }
      
      before do
        put :update, :id => client.id, :client => {
          :name => client_name
        }, :user => {
          :name => user_name
        }
      end
      
      it "should update client data" do
        client.reload.name.should eql(client_name)
      end
      
      it "should update user data" do
        user.reload.name.should eql(user_name)
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "redirection", :clients
    end
    
    context "with invalid data" do
      let!(:old_email) { client.email }
      
      before do
        put :update, :id => client.id, :client => {
          :email => 'invalid_email'
        }, :user => {
        }
      end
      
      it "should not update client data" do
        client.reload.email.should eql(old_email)
      end
      
      it_should_behave_like "flash error"
      it_should_behave_like "list of", :clients, [:client]
      it_should_behave_like "render template", :index
    end
  end
  
  describe "destroy" do
    render_views
    
    let!(:client) { Factory(:client) }
    let!(:user) { Factory(:user, :client => client) }
    
    before do
      delete :destroy, :id => client.id
    end
    
    it "should delete client" do
      expect {client.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end
    
    it "should delete user" do
      expect {user.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end
    
    it "should response with valid json" do
      result = response.body
      
      match = result.match(/{"html":"(.*)","success":true}/)
      html = match[1]
      
      match.should_not be_nil
      html.should_not =~ /<td>#{client.name}<\/td>/
      html.should include('No clients found')
    end
  end
end
