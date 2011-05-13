require 'spec_helper'

include SharedMethods

describe CurrenciesController do
  describe "index" do
    let!(:currency) { Factory(:dollar) }
    
    before do
      login_as(:admin)
      get :index
    end
    
    it_should_behave_like "new resource", :currency
    it_should_behave_like "render template", :index
    it_should_behave_like "list of", :currencies, Array, :currency
  end
  
  describe "new" do
    before do
      login_as(:admin)
      get :new
    end
    
    it_should_behave_like "new resource", :currency
    it_should_behave_like "render template", :form
  end
  
  describe "create" do
    let!(:count) { Currency.count }
    
    before { login_as(:admin) }
    
    context "with valid data" do
      before do
        get :create, :currency => {
          :name => 'yen', 
          :plural => 'yens', 
          :symbol => 'Y',
          :prefix => 1
        }
      end
      
      it "should create currency" do
        Currency.count.should eql(count + 1)
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "redirection", :currencies
    end
    
    context "with invalid data" do
      before do
        get :create, :currency => {}
      end
      
      it "should not create currency" do
        Currency.count.should eql(count)
      end
      
      it_should_behave_like "flash error"
      it_should_behave_like "render template", :index
      it_should_behave_like "new resource", :currency
      it_should_behave_like "list of", :currencies
    end
  end
  
  describe "edit" do
    let!(:currency) { Factory(:dollar) }
    
    before do
      login_as(:admin)
      get :edit, :id => currency.id
    end
    
    it_should_behave_like "render template", :form
    it_should_behave_like "existing resource", :currency
  end
  
  describe "update" do
    let!(:currency) { Factory(:dollar) }
    
    before { login_as(:admin) }
    
    context "with valid data" do
      let(:name) { 'zloty' }
      
      before do
        put :update, :id => currency.id, :currency => {:name => name}
      end
      
      it "should update currency data" do
        currency.reload.name.should eql(name)
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "redirection", :currencies
    end
    
    context "with invalid data" do
      let!(:old_name) { currency.name }
      
      before do
        put :update, :id => currency.id, :currency => {:name => ''}
      end
      
      it "should not update currency data" do
        currency.reload.name.should eql(old_name)
      end
      
      it_should_behave_like "flash error"
      it_should_behave_like "list of", :currencies, Array, :currency
      it_should_behave_like "render template", :index
    end
  end
  
  describe "destroy" do
    render_views
    
    let!(:currency) { Factory(:dollar) }
    
    before do
      login_as(:admin)
      delete :destroy, :id => currency.id
    end
    
    it "should delete currency" do
      expect {currency.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end
    
    it "should response with valid json" do
      result = response.body
      
      match = result.match(/{"html":"(.*)","success":true}/)
      html = match[1]
      
      match.should_not be_nil
      html.should_not =~ /<td>#{currency.name}<\/td>/
      html.should include('No currencies found')
    end
  end
end
