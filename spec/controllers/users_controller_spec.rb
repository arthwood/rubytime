require 'spec_helper'

include SharedMethods

describe UsersController do
  describe "index" do
    let!(:admin) { Factory(:admin) }
    let!(:employee) { Factory(:user) }
    let!(:client_user) { Factory(:client_user) }
    
    before do
      login_as(:admin)
      get :index
    end
    
    it_should_behave_like "render template", :index
    it_should_behave_like "new resource", :user
    it_should_behave_like "list of", :admins, ActiveRecord::Relation, :admin
    it_should_behave_like "list of", :employees, ActiveRecord::Relation, :employee
    it_should_behave_like "list of", :clients_users, ActiveRecord::Relation, :client_user
  end
  
  describe "new" do
    before do
      login_as(:admin)
      get :new
    end
    
    it_should_behave_like "new resource", :user
    it_should_behave_like "render template", :form
  end
  
  describe "create" do
    let!(:admin) { Factory(:admin) }
    let!(:developer) { Factory(:developer) }
    let!(:client) { Factory(:client) }
    let!(:count) { User.count }
    
    before { login_as(:admin, admin) }
    
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
      
      it "should create user" do
        User.count.should eql(count + 1)
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "redirection", :users
    end
    
    context "with invalid data" do
      before do
        get :create, :user => {}
      end
      
      it "should not create user" do
        User.count.should eql(count)
      end
      
      it_should_behave_like "flash error"
      it_should_behave_like "render template", :index
      it_should_behave_like "list of", :admins, ActiveRecord::Relation
    end
  end
  
  describe "edit" do
    let!(:user) { Factory(:user) }
    
    before do
      login_as(:admin)
      get :edit, :id => user.id
    end
    
    it_should_behave_like "render template", :form
    it_should_behave_like "existing resource", :user
  end
  
  describe "update" do
    let!(:user) { Factory(:user) }
    
    before do
      login_as(:admin)
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
      it_should_behave_like "redirection", :users
    end
    
    context "with invalid data" do
      let!(:old_email) { user.email }
      
      before do
        put :update, :id => user.id, :user => {
          :email => 'invalid_email'
        }
      end
      
      it "should not update user data" do
        user.reload.email.should eql(old_email)
      end
      
      it_should_behave_like "flash error"
      it_should_behave_like "list of", :employees, ActiveRecord::Relation, :user
      it_should_behave_like "render template", :index
    end
  end
  
  describe "destroy" do
    render_views
    
    let!(:developer) { Factory(:developer) }
    let!(:user) { Factory(:user) }
    
    before do
      login_as(:admin)
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
        subject.current_user.should eql(user)
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
