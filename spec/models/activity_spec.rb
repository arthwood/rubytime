require 'spec_helper'

describe Activity do
  subject { Factory.build(:activity) }
  
  describe "#time_spent" do
    context "if it wasn't set before" do
      it "should return proper value" do
        subject.time_spent.should == '7:15'
      end
    end
    
    context "if it was set before" do
      let(:time_spent) { '7:30' }
      before { subject.time_spent = time_spent }
      
      it "should return the same value" do
        subject.time_spent.should == time_spent
      end
    end
  end
  
  describe "#to_json" do
    context "for default activity" do
      it "should return basic data" do
        result = subject.to_json
        
        result.should =~ /{"activity":{(.*)}}/
        result.should =~ /"comments":"#{subject.comments}"/
        result.should =~ /"date":"(.*)"/
        result.should =~ /"id":#{subject.id}/
        result.should =~ /"invoice_id":null/
        result.should_not =~ /"password_hash":"(.*)"/
      end
    end
    
    context "for invoiced activity" do
      subject { Factory.build(:invoiced_activity) }
      
      it "should return invoice data" do
        result = subject.to_json
        match = result.match /"invoice":{(.*)}/
        invoice = match[1]
        invoice.should =~ /"id":#{subject.invoice.id}/
        invoice.should =~ /"name":"#{subject.invoice.name}"/
      end
    end
  end
  
  describe ".search" do
    let!(:activity_1) { Factory(:activity) }
    let!(:activity_2) { Factory(:activity) }
    
    context "when no filter is set" do
      let(:filter) do
        ActivityFilter.new(nil)
      end
      
      it "should return both activity_1 and activity_2" do
        result = Activity.search(filter)
        result.size.should == 2
        result.should include(activity_1, activity_2)
      end
    end
    
    context "for date range filter" do
      before do
        activity_2.update_attribute(:date, activity_1.date.ago(2.months))
      end
      
      let(:filter) do
        ActivityFilter.new(
          :from => activity_1.date.ago(1.month).to_s(:db), 
          :to => activity_1.date.since(1.month).to_s(:db)
        )
      end
      
      it "should return only one activity" do
        result = Activity.search(filter)
        result.size.should == 1
        result.should include(activity_1)
      end
    end
    
    context "for client range filter" do
      let(:filter) do
        ActivityFilter.new(:client_id => activity_1.project.client.id)
      end
      
      it "should return only one activity" do
        result = Activity.search(filter)
        result.size.should == 1
        result.should include(activity_1)
      end
    end
  end
end
