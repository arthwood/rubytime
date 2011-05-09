require 'spec_helper'

describe Client do
  describe "#collaborators" do
    subject { Factory(:client) }
    
    let!(:project) { Factory(:project, :client => subject) }
    let!(:user) { Factory(:user) }
    let!(:activity_1) { Factory(:activity, :project => project) }
    let!(:activity_2) { Factory(:activity, :project => project, :user => user) }
    
    it "should include proper users" do
      result = subject.collaborators
      result.size.should == 2
      result.should include(activity_1.user, user)
    end
  end
end
