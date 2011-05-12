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
  
=begin
  describe "destroy" do
    render_views
    
    let!(:invoice) { Factory(:invoice) }
    
    before do
      login_as_admin
      delete :destroy, :id => invoice.id
    end
    
    it "should delete invoice" do
      expect {invoice.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end
    
    it "should response with valid json" do
      result = response.body
      
      match = result.match(/{"html":"(.*)","success":true}/)
      html = match[1]
      
      match.should_not be_nil
      html.should_not =~ /<td>#{invoice.name}<\/td>/
      html.should include('No invoices found')
    end
  end
=end
end
