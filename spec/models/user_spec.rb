require 'spec_helper'

describe User do
  context 'predefined admin user' do
    subject do
      User.new(CONFIG[:admin]).tap {|i| i.password_confirmation = CONFIG[:admin][:password] }
    end
    
    it { should be_valid }
  end
  
  describe "#password" do
    subject { Factory.build(:user) }
    
    context "when password_hash is not set" do
      before { subject.password_hash = nil }
      
      it "should be nil" do
        subject.password.should be_nil
      end
    end
    
    context "when password_hash is set" do
      it "should not be nil" do
        subject.password.should_not be_nil
      end
      
      it "should be type of Password" do
        subject.password.class.should == BCrypt::Password
      end
    end
  end
  
  describe "#to_json" do
    it "should not expose secure data" do
      result = subject.to_json
      result.should_not =~ /"password_hash":"(.*)"/
      result.should_not =~ /"login_key":"(.*)"/
    end
  end
  
  describe "#client?" do
    context "when user is not a client" do
      subject { Factory(:user) }
    
      it { should_not be_client }
    end
    
    context "when user is a client" do
      subject { Factory(:client_user) }
    
      it { should be_client }
    end
  end
  
  describe "#employee?" do
    context "when user is not a client" do
      subject { Factory(:user) }
    
      it { should be_employee }
    end
    
    context "when user is a client" do
      subject { Factory(:client_user) }
    
      it { should_not be_employee }
    end
  end
  
  describe "#editor?" do
    context "when user is admin" do
      subject { Factory(:admin) }
    
      it { should be_editor }
    end
    
    context "when user is employee" do
      subject { Factory(:user) }
    
      it { should be_editor }
    end
    
    context "when user is client" do
      subject { Factory(:client_user) }
    
      it { should_not be_employee }
    end
  end
end
