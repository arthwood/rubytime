require 'spec_helper'

describe Rubytime::Util do
  let(:x) { subject.class }
  
  describe "format_currency" do
    context "with first decimal place only" do
      let!(:currency) { Factory(:dollar) }
      
      it "should return valid value" do
        x.format_currency(currency, 5.4).should eql('$5.40')
      end
    end
    
    context "with prefix" do
      let!(:currency) { Factory(:dollar) }
      
      it "should return valid value" do
        x.format_currency(currency, 5.43).should eql('$5.43')
      end
    end
    
    context "with postfix" do
      let!(:currency) { Factory(:euro) }
      
      it "should return valid value" do
        x.format_currency(currency, 5.43).should eql('5.43e')
      end
    end
  end
  
  describe "format_currency_hr" do
    let!(:role) { Factory(:developer) }
    let!(:currency) { Factory(:pound) }
    let!(:hourly_rate) { Factory(:hourly_rate) }
    
    it "should return valid value" do
      x.format_currency_hr(hourly_rate).should eql('p40.00')
    end
  end
  
  describe "format_time_spent" do
    it "should return valid value" do
      x.format_time_spent(543).should eql('9:03')
    end
  end
  
  describe "format_time_spent_decimal" do
    it "should return valid value" do
      x.format_time_spent_decimal(543).should eql('9.05')
    end
  end
  
  describe "format_date" do
    context "with specified separator" do
      it "should return valid value" do
        x.format_date(Date.parse('2011/05/03'), ' ').should eql('2011 05 03')
      end
    end
    
    context "with default separator" do
      it "should return valid value" do
        x.format_date(Date.parse('2011/05/03')).should eql('2011-05-03')
      end
    end
  end
end
