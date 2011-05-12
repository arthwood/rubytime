require 'spec_helper'

include SharedMethods

describe SessionsController do
  describe "create" do
    let(:password) { "asdf1234" }
    let!(:user) { Factory(:user) }
    
    describe "cleaning session" do
      let(:session_data) { "some data" }
      
      before { session[:some_data] = session_data }
      
      context "with valid data" do
        it "should clear the session" do
          get :create, :session => {:login => user.login, :password => password}
          
          session[:some_data].should be_nil
        end
      end
      
      context "with invalid data" do
        it "should not clear the session" do
          get :create, :session => {:login => user.login, :password => ''}
          
          session[:some_data].should eql(session_data)
        end
      end
    end
    
    context "with valid data" do
      before do
        get :create, :session => {:login => user.login, :password => password}
      end
      
      it "should log in user" do
        subject.current_user.should eql(user)
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "root redirection"
    end
    
    context "with invalid data" do
      context "user invalid" do
        before do
          get :create, :session => {:login => "#{user.login}x", :password => password}
        end
        
        it "should not log in" do
          subject.current_user.should be_nil
        end
        
        it_should_behave_like "flash error"
        it_should_behave_like "render new"
      end
    
      context "password invalid" do
        before do
          get :create, :session => {:login => user.login, :password => ''}
        end
        
        it "should not log in" do
          subject.current_user.should be_nil
        end
        
        it_should_behave_like "flash error"
        it_should_behave_like "render new"
      end
    end
  end
  
  describe "destroy" do
    before { login_as_user }
    
    describe "cleaning session" do
      let(:session_data) { "some data" }
      
      before do 
        session[:some_data] = session_data
        
        delete :destroy
      end
      
      it "should clear the session" do
        session[:some_data].should be_nil
      end
    end
    
    describe "other actions" do
      before do
        delete :destroy
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "root redirection"
    end
  end
end
