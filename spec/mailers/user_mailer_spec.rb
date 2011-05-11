require 'spec_helper'

describe UserMailer do
  before :all do
    ActionMailer::Base.default_url_options[:host] = 'test.host'
  end
  
  let!(:user) { Factory(:user) }
  
  describe "reset" do
    let(:mailer) { UserMailer.reset(user).deliver }
    
    it "should render body" do
      mailer.body.should include(user.login_key)
    end
  end
end
