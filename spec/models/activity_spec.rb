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
    let!(:activity_3) { Factory(:invoiced_activity) }
    
    context "when no filter is set" do
      let(:filter) do
        ActivityFilter.new(nil)
      end
      
      it "should return both activity_1 and activity_2" do
        result = subject.class.search(filter)
        result.size.should == 3
        result.should include(activity_1, activity_2, activity_3)
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
        result = subject.class.search(filter)
        result.size.should == 2
        result.should include(activity_1, activity_3)
      end
    end
    
    context "for client range filter" do
      let(:filter) do
        ActivityFilter.new(:client_id => activity_1.project.client.id)
      end
      
      it "should return only one activity" do
        result = subject.class.search(filter)
        result.size.should == 1
        result.should include(activity_1)
      end
    end
    
    context "invoice filter" do
      context 'all' do
        let(:filter) do
          ActivityFilter.new(:invoice_filter => :all)
        end
        
        it "should return all activities" do
          result = subject.class.search(filter)
          result.size.should == 3
          result.should include(activity_1, activity_2, activity_3)
        end
      end
      
      context 'invoiced' do
        let(:filter) do
          ActivityFilter.new(:invoice_filter => :invoiced)
        end
        
        it "should return invoiced activities" do
          result = subject.class.search(filter)
          result.size.should == 1
          result.should include(activity_3)
        end
      end
      
      context 'not_invoiced' do
        let(:filter) do
          ActivityFilter.new(:invoice_filter => :not_invoiced)
        end
        
        it "should return invoiced activities" do
          result = subject.class.search(filter)
          result.size.should == 2
          result.should include(activity_1, activity_2)
        end
      end
    end
  end
  
  describe ".search_missed" do
    context "for specific user" do
      let(:date) { Date.current }
      let(:days) { date.beginning_of_month.upto(date.end_of_month).to_a.reject {|i| i.saturday? || i.sunday?} }
      let!(:user) { Factory(:user) }
      let(:filter) do
        MissedActivityFilter.new(:user_id => user.id)
      end
      
      context "when there are no activities" do
        it "should return all days of current month without weekends" do
          result = subject.class.search_missed(filter)
          result.keys.should == [user]
          result[user].should == days
        end
      end
      
      context "when there are any activities" do
        let!(:activity) { Factory(:activity, :user => user, :date => days[0]) }
        
        it "should not include activity date" do
          result = subject.class.search_missed(filter)
          result[user].should_not include(activity.date)
        end
        
        context "and there are days off" do
          let!(:free_day) { Factory(:free_day, :user => user, :date => days[1]) }
          
          it "should not include free day" do
            result = subject.class.search_missed(filter)
            result[user].should_not include(free_day.date)
          end
        end
      end
    end
  end

  describe "#to_csv_row" do
    subject { Factory(:activity) }
    
    let!(:role) { Factory(:developer) }
    let!(:currency) { Factory(:pound) }
    let!(:hourly_rate) { Factory(:hourly_rate, :project => subject.project, :date => subject.date.ago(1.month)) }
    
    it "should include data" do
      result = subject.to_csv_row
      
      result.should include(subject.date)
      result.should include(subject.comments)
      result.should include(subject.project.name)
      result.should include(subject.project.client.name)
      result.should include(subject.user.name)
      result.should include('7.25')
      result.should include('p290.00')
    end
  end
  
  describe "#total_value" do
    subject { Factory(:activity) }
    
    let!(:developer) { Factory(:developer) }
    let!(:pound) { Factory(:pound) }
    let!(:hourly_rate) { Factory(:hourly_rate, :project => subject.project) }
    
    it "should return proper value" do
      subject.total_value.should == 290.00
    end
  end
  
  describe ".total_value" do
    let!(:pound) { Factory(:pound) }
    let!(:dollar) { Factory(:dollar) }
    let!(:developer) { Factory(:developer) }
    let!(:project) { Factory(:project) }
    let!(:user) { Factory(:user) }
    
    let!(:previous_hourly_rate) {
      Factory(:hourly_rate, :project => project)
    }
    let!(:current_hourly_rate) {
      Factory(:hourly_rate, :project => project, :date => 1.week.ago, :value => 50.00, :currency => dollar)
    }
    let!(:previous_activity) {
      Factory(:activity, :project => project, :user => user, :date => 10.days.ago, :minutes => 420)
    }
    let!(:current_activity) {
      Factory(:activity, :project => project, :user => user, :date => 2.days.ago, :minutes => 480)
    }
    
    it "should return proper value" do
      subject.class.total_value([previous_activity, current_activity]).should == ['p280.00', '$400.00']
    end
  end

  describe ".total_time" do
    let!(:project) { Factory(:project) }
    let!(:user) { Factory(:user) }
    
    let!(:previous_activity) {
      Factory(:activity, :project => project, :user => user, :date => 2.days.ago, :minutes => 420)
    }
    let!(:current_activity) {
      Factory(:activity, :project => project, :user => user, :date => 1.day.ago, :minutes => 480)
    }
    
    it "should return proper value" do
      subject.class.total_time([previous_activity, current_activity]).should == 900
    end
  end
  
  describe ".to_csv" do
    let!(:currency) { Factory(:pound) }
    let!(:role) { Factory(:developer) }
    let!(:hourly_rate) { Factory(:hourly_rate) }
    let!(:project) { hourly_rate.project }
    let!(:activity) { Factory(:activity, :project => project) }
    
    it "should return proper value" do
      result = subject.class.to_csv([activity])
      result.should be_instance_of(String)
      result.should_not be_blank
    end
  end
  
  describe ".to_pdf" do
    let!(:activity) { Factory(:activity) }
    let(:activities) { [activity] }
    let(:title) { 'title' }
    let(:hide_users) { false }
    
    it "should return proper value" do
      ActivityReport.any_instance.should_receive(:to_pdf).once.with(activities, title, hide_users)
      subject.class.to_pdf(activities, title, hide_users)
    end
  end
end
