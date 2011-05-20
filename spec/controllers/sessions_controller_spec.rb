require 'spec_helper'

include SharedMethods

shared_examples_for "successful login" do
  it "should log in user" do
    subject.current_user.should eql(user)
  end

  it_should_behave_like "flash info"
end

describe SessionsController do
  describe "create" do
    let(:password) { "asdf1234" }
    let!(:user) { Factory(:user) }
    
    describe "cleaning session" do
      let(:session_data) { "some data" }
      
      before { session[:some_data] = session_data }
      
      context "with valid data" do
        before { get :create, :session => {:login => user.login, :password => password} }
        
        it "should clear the session" do
          session[:some_data].should be_nil
        end
      end
      
      context "with invalid data" do
        before { get :create, :session => {:login => user.login, :password => ''} }
        
        it "should not clear the session" do
          session[:some_data].should eql(session_data)
        end
      end
    end
    
    context "with valid data" do
      context "without return_to" do
        before do 
          get :create, :session => {:login => user.login, :password => password}
        end
        
        it_should_behave_like "successful login"
        it_should_behave_like "root redirection"
      end
      
      context "with return_to" do
        before do
          session[:return_to] = '/activities/calendar'
          
          get :create, :session => {:login => user.login, :password => password}
        end
        
        it_should_behave_like "successful login"
        it_should_behave_like "redirection", '/activities/calendar'
      end
    end
    
    context "with invalid data" do
      context "user invalid" do
        before { get :create, :session => {:login => "#{user.login}x", :password => password} }
        
        it "should not log in" do
          subject.current_user.should be_nil
        end
        
        it_should_behave_like "flash error"
        it_should_behave_like "render template", :new
      end
    
      context "password invalid" do
        before { get :create, :session => {:login => user.login, :password => ''} }
        
        it "should not log in" do
          subject.current_user.should be_nil
        end
        
        it_should_behave_like "flash error"
        it_should_behave_like "render template", :new
      end
    end
  end
  
  describe "destroy" do
    before { login_as(:user) }
    
    describe "cleaning session" do
      let(:session_data) { "some data" }
      
      before { session[:some_data] = session_data } 
      before { delete :destroy }
      
      it "should clear the session" do
        session[:some_data].should be_nil
      end
    end
    
    describe "other actions" do
      before { delete :destroy }
      
      it_should_behave_like "flash info"
      it_should_behave_like "root redirection"
    end
  end
end
