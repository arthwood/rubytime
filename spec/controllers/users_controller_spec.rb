require 'spec_helper'

include SharedMethods

def create_list_data
  let!(:admin) { Factory(:admin) }
  let!(:employee) { Factory(:user) }
  let!(:client_user) { Factory(:client_user) }
end

describe UsersController do
  include RubytimeHelper
  
  shared_examples_for "index redirection" do
    it "should redirect to :index" do
      response.should be_redirect
      response.should redirect_to(users_path)
    end
  end

  shared_examples_for "new user" do
    it "should set @user variable" do
      var = assigns(:user)
      var.should be_an_instance_of(User)
      var.should be_new_record
    end
  end
  
  shared_examples_for "existing user" do
    it "should set proper @user variable" do
      assigns(:user).should eql(user)
    end
  end
  
  shared_examples_for "list data" do
    it "should set @admins variable" do
      var = assigns(:admins)
      var.should be_an_instance_of(ActiveRecord::Relation)
      var.should include(admin)
    end
    
    it "should set @employees variable" do
      var = assigns(:employees)
      var.should be_an_instance_of(ActiveRecord::Relation)
      var.should include(employee)
    end
    
    it "should set @clients_users variable" do
      var = assigns(:clients_users)
      var.should be_an_instance_of(ActiveRecord::Relation)
      var.should include(client_user)
    end
  end
  
  describe "index" do
    create_list_data
    
    before do
      login_as_admin
      get :index
    end
    
    it_should_behave_like "render index"
    it_should_behave_like "new user"
    it_should_behave_like "list data"
  end
  
  describe "new" do
    before do
      login_as_admin
      get :new
    end
    
    it_should_behave_like "new user"
    it_should_behave_like "render form"
  end
  
  describe "create" do
    let!(:developer) { Factory(:developer) }
    let!(:client) { Factory(:client) }
    let!(:count) { User.count }
    
    before { login_as_admin }
    
    context "with valid data" do
      before do
        get :create, :user => {
          :group => 0, 
          :role_id => developer.id, 
          :client_id => client.id, 
          :name => 'Rick', 
          :login => 'rick', 
          :email => 'rick@email.com', 
          :password => 'secret123', 
          :password_confirmation => 'secret123', 
          :active => 1, 
          :admin => 0
        }
      end
      
      it "should render create user" do
        User.count.should eql(count + 1)
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "index redirection"
    end
    
    context "with invalid data" do
      create_list_data
      
      before do
        get :create, :user => {}
      end
      
      it_should_behave_like "flash error"
      it_should_behave_like "render index"
      it_should_behave_like "list data"
    end
  end
  
  describe "edit" do
    let!(:user) { Factory(:user) }
    
    before do
      login_as_admin
      get :edit, :id => user.id
    end
    
    it_should_behave_like "render form"
    it_should_behave_like "existing user"
  end
  
  describe "update" do
    let!(:user) { Factory(:user) }
    
    before do
      login_as_admin
    end
    
    context "with valid data" do
      let(:name) { 'Mike' }
      
      before do
        put :update, :id => user.id, :user => {
          :name => name
        }
      end
      
      it "should update user data" do
        user.reload.name.should eql(name)
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "index redirection"
    end
    
    context "with invalid data" do
      create_list_data
      
      let!(:old_email) { user.email }
      
      before do
        put :update, :id => user.id, :user => {
          :email => 'invalid_email'
        }
      end
      
      it "should not user data" do
        user.reload.email.should eql(old_email)
      end
      
      it_should_behave_like "flash error"
      it_should_behave_like "list data"
      it_should_behave_like "render index"
      
      it "@employees collection should include user" do
        assigns(:employees).should include(user)
      end
    end
  end
  
  describe "destroy" do
    render_views
    
    let!(:developer) { Factory(:developer) }
    let!(:user) { Factory(:user) }
    
    before do
      login_as_admin
      delete :destroy, :id => user.id
    end
    
    it "should delete user" do
      expect {user.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end
    
    it "should response with valid json" do
      result = response.body
      
      match = result.match(/{"html":"(.*)","success":true}/)
      html = match[1]
      
      match.should_not be_nil
      html.should_not =~ /<td>#{user.name}<\/td>/
      html.should include('No employees found')
    end
  end

  describe "do_request_password" do
    context "when email is valid" do
      let!(:user) { Factory(:user) }
      let(:deliver_mock) { mock(:deliver => nil) }
      
      describe "sending email" do
        it "should send email" do
          UserMailer.should_receive(:reset).once.with(user).and_return(deliver_mock)
        
          post :do_request_password, :reset_password => {:email => user.email}
        end
      end
      
      describe "other actions" do
        before do
          UserMailer.stub!(:reset).and_return(deliver_mock)
          
          post :do_request_password, :reset_password => {:email => user.email}
        end
        
        it "should create login key" do
          user.reload.login_key.should_not be_nil
        end
        
        it_should_behave_like "flash info"
        
        it "should redirect to login page" do
          response.should redirect_to(login_url)
        end
      end
    end
    
    context "when email is not valid" do
      before do
        post :do_request_password, :reset_password => {:email => 'yyy'}
      end
      
      it_should_behave_like "flash error"
      
      it "should redirect to login page" do
        response.should redirect_to(login_url)
      end
    end
  end
  
  describe "reset" do
    let(:login_key) { 'asdf1234' }
    
    context "when key is valid" do
      let!(:user) { Factory(:user, :login_key => login_key) }
      
      before do
        get :reset, :key => login_key
      end
      
      it "should clear login key" do
        user.reload.login_key.should be_nil
      end
      
      it "should login user" do
        current_user.should eql(user)
      end
      
      it "should redirect to root_url" do
        response.should redirect_to(root_url)
      end
    end
    
    context "when key is not valid" do
      before do
        get :reset, :key => login_key
      end
      
      it_should_behave_like "flash error"
      
      it "should redirect to login page" do
        response.should redirect_to(login_url)
      end
    end
  end
end
