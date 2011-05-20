require 'spec_helper'

include SharedMethods

describe RubytimeHelper do
  describe "current_user=" do
    let!(:user) { Factory(:user) }
    
    before do
      self.current_user = user
    end
    
    it "should set user_id in session" do
      session[:user_id].should eql(user.id)
    end
  end
  
  describe "current_user" do
    context "when session user_id is blank" do
      it "should be nil" do
        current_user.should be_nil
      end
    end
    
    context "when @current_user is set" do
      let!(:user) { Factory(:user) }
      
      before do
        instance_variable_set(:@current_user, user)
      end
      
      it "should return that user" do
        current_user.should eql(user)
      end
    end
    
    context "when session user_id is set" do
      before do
        session[:user_id] = 1
      end
      
      context "and user does not exists" do
        it "should be nil" do
          current_user.should be_nil
        end
      end
      
      context "and user does exists" do
        let!(:user) { Factory(:user, :id => session[:user_id]) }
        
        it "should return taht user" do
          current_user.should eql(user)
        end
      end
    end
  end
  
  describe "logged_in?" do
    subject { self }
    
    context "when user is logged_in" do
      before { login_as(:user) }
      
      it { should be_logged_in }
    end
    
    context "when user is not logged_in" do
      it { should_not be_logged_in }
    end
  end
end
