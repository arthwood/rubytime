require 'spec_helper'

describe ActivityReport do
  let!(:currency) { Factory(:pound) }
  let!(:role) { Factory(:developer) }
  let!(:activity) { Factory(:activity) }
  let!(:hourly_rate) { Factory(:hourly_rate, :project => activity.project) }
  
  describe "#to_pdf" do
    it "should render PDF" do
      result = subject.to_pdf([activity], 'My PDF', false)
      
      result.should be_instance_of(String)
      result.should_not be_blank
    end
  end
end
