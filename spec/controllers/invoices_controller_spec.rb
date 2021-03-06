require 'spec_helper'

include SharedMethods

describe InvoicesController do
  let!(:user) { Factory(:admin) }
  
  before { login_as(user) }
  
  describe "index" do
    let!(:invoice) { Factory(:invoice) }
    
    before do
      get :index
    end
    
    it_should_behave_like "new resource", :invoice
    it_should_behave_like "render template", :index
    it_should_behave_like "list of", :invoices, [:invoice]
  end
  
  describe "new" do
    before do
      get :new
    end
    
    it_should_behave_like "new resource", :invoice
    it_should_behave_like "render template", :form
  end
  
  describe "show" do
    let!(:client) { Factory(:client, :name => "microsoft") }
    let!(:invoice) { Factory(:invoice, :client => client) }
    let(:filename) { 'invoice_microsoft_2011_05_20' }
    
    before do
      Date.stub!(:current).and_return(Date.parse('2011/05/20'))
    end
    
    context "csv" do
      before do
        get :show, :id => invoice.id, :format => :csv
      end
      
      it_should_behave_like "success"
      it_should_behave_like "variable", :invoice
      it_should_behave_like "variable", :filename
    end
    
    context "pdf" do
      before do
        get :show, :id => invoice.id, :format => :pdf
      end
      
      it_should_behave_like "success"
      it_should_behave_like "variable", :invoice
      it_should_behave_like "variable", :filename
    end
  end
  
  describe "create" do
    let!(:client) { Factory(:client) }
    let!(:count) { Invoice.count }
    
    context "with valid data" do
      before do
        get :create, :invoice => {
          :name => 'Invoice 6', 
          :client_id => client.id,
          :notes => 'notes',
          :issued_at => '2011-02-11'
        }
      end
      
      it "should create invoice" do
        Invoice.count.should eql(count + 1)
      end
      
      it "should have current_user as an owner" do
        assigns(:invoice).user.should eql(user)
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "redirection", :invoices
    end
    
    context "with invalid data" do
      before do
        get :create, :invoice => {}
      end
      
      it "should not create invoice" do
        Invoice.count.should eql(count)
      end
      
      it_should_behave_like "flash error"
      it_should_behave_like "render template", :index
      it_should_behave_like "new resource", :invoice
      it_should_behave_like "list of", :invoices
    end
  end
  
  describe "edit" do
    let!(:invoice) { Factory(:invoice) }
    
    before do
      get :edit, :id => invoice.id
    end
    
    it_should_behave_like "render template", :form
    it_should_behave_like "variable", :invoice
  end
  
  describe "update" do
    let!(:invoice) { Factory(:invoice) }
    
    context "with valid data" do
      let(:name) { 'Invoice 7' }
      
      before do
        put :update, :id => invoice.id, :invoice => {:name => name}
      end
      
      it "should update invoice data" do
        invoice.reload.name.should eql(name)
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "redirection", :invoices
    end
    
    context "with invalid data" do
      let!(:old_name) { invoice.name }
      
      before do
        put :update, :id => invoice.id, :invoice => {:name => ''}
      end
      
      it "should not update invoice data" do
        invoice.reload.name.should eql(old_name)
      end
      
      it_should_behave_like "flash error"
      it_should_behave_like "list of", :invoices, [:invoice]
      it_should_behave_like "render template", :index
    end
  end
  
  describe "destroy" do
    render_views
    
    let!(:invoice) { Factory(:invoice) }
    
    before do
      delete :destroy, :id => invoice.id
    end
    
    it "should delete invoice" do
      expect {invoice.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end
    
    it "should response with valid json" do
      result = response.body
      
      match = result.match(/{"html":"(.*)","success":true}/)
      html = match[1]
      
      match.should_not be_nil
      html.should_not =~ /<td>#{invoice.name}<\/td>/
      html.should include('No invoices found')
    end
  end
end
