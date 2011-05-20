require 'spec_helper'

describe Invoice do
  subject { Factory(:invoice) }
  
  let!(:activity) { Factory(:invoiced_activity, :invoice => subject) }
  
  describe "#to_csv" do
    before do
      Activity.should_receive(:to_csv).with([activity])
    end
    
    it "should call Activity.to_csv" do
      subject.to_csv
    end
  end
  
  describe "#to_pdf" do
    before do
      Activity.should_receive(:to_pdf).with([activity], subject.name, false)
    end
    
    it "should call Activity.to_pdf" do
      subject.to_pdf
    end
  end
end
