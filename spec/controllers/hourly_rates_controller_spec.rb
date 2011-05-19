require 'spec_helper'

include SharedMethods

describe HourlyRatesController do
  before { login_as(:admin) }
  
=begin
  describe "new" do
    let!(:project) { Factory(:project) }
    let!(:role) { Factory(:developer) }
    
    before do
      get :new, :project_id => project.id, :role_id => role.id
    end
    
    it_should_behave_like "new resource", :hourly_rate
    it_should_behave_like "variable", :project
    it_should_behave_like "render template", :form
  end
  
  describe "create" do
    let!(:project) { Factory(:project) }
    let!(:role) { Factory(:developer) }
    let!(:currency) { Factory(:pound) }
    let!(:count) { HourlyRate.count }
    
    context "with valid data" do
      before do
        post :create, :project_id => project.id, :hourly_rate => {
          :role_id => role.id,
          :date => Date.current.to_s(:db),
          :value => 35.00,
          :currency_id => currency.id
        }
      end
      
      it "should create hourly_rate" do
        HourlyRate.count.should eql(count + 1)
      end
      
      it "should have all relations assigned" do
        var = assigns(:hourly_rate)
        var.project.should eql(project)
        var.role.should eql(role)
        var.currency.should eql(currency)
      end
      
      it_should_behave_like "render json", /{"success":true,"html":"(.*)"}/
    end
    
    context "with invalid data" do
      before do
        get :create, :project_id => project.id, :hourly_rate => {}
      end
      
      it "should not create hourly rate" do
        HourlyRate.count.should eql(count)
      end
      
      it_should_behave_like "render json", /{"success":false,"html":"(.*)"}/
    end
  end
  
  describe "edit" do
    let!(:hourly_rate) { Factory(:hourly_rate) }
    let(:project) { hourly_rate.project }
    
    before do
      get :edit, :project_id => project.id, :id => hourly_rate.id
    end
    
    it_should_behave_like "render template", :form
    it_should_behave_like "variable", :hourly_rate
  end
  
  describe "update" do
    let!(:hourly_rate) { Factory(:hourly_rate) }
    let!(:currency) { Factory(:dollar) }
    let(:project) { hourly_rate.project }
    
    context "with valid data" do
      before do
        put :update, :project_id => project.id, :id => hourly_rate.id, :hourly_rate => {:currency_id => currency.id}
      end
      
      it "should update hourly rate data" do
        hourly_rate.reload.currency.should eql(currency)
      end
      
      it_should_behave_like "render json", /{"success":true,"hourly_rate":{(.*)}}/
    end
    
    context "with invalid data" do
      let!(:old_currency) { hourly_rate.currency }
      
      before do
        put :update, :project_id => project.id, :id => hourly_rate.id, :hourly_rate => {:currency_id => nil}
      end
      
      it "should not update hourly rate data" do
        hourly_rate.reload.currency.should eql(old_currency)
      end
      
      it_should_behave_like "render json", /{"success":false,"html":"(.*)"}/
    end
  end
=end
  
  describe "destroy" do
    let!(:hourly_rate) { Factory(:hourly_rate) }
    let(:project) { hourly_rate.project }
    
    before do
      delete :destroy, :project_id => project.id, :id => hourly_rate.id
    end
    
    it "should delete hourly rate" do
      expect {hourly_rate.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end
    
    it_should_behave_like "render json", /{"success":true,"hourly_rate":{(.*)}}/
  end
end
