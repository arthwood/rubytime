require 'spec_helper'

include SharedMethods

describe InvoicesController do
  describe "index" do
    let!(:invoice) { Factory(:invoice) }
    
    before do
      login_as(:admin)
      get :index
    end
    
    it_should_behave_like "new resource", :invoice
    it_should_behave_like "render template", :index
    it_should_behave_like "list of", :invoices, [:invoice]
  end
  
  describe "new" do
    before do
      login_as(:admin)
      get :new
    end
    
    it_should_behave_like "new resource", :invoice
    it_should_behave_like "render template", :form
  end
  
  describe "create" do
    let!(:client) { Factory(:client) }
    let!(:count) { Invoice.count }
    let!(:admin) { Factory(:admin) }
    
    before do
      login_as(:admin)
      subject.stubs(:current_user).returns(admin)
    end
    
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
        assigns(:invoice).user.should eql(admin)
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
      login_as(:admin)
      get :edit, :id => invoice.id
    end
    
    it_should_behave_like "render template", :form
    it_should_behave_like "variable", :invoice
  end
  
  describe "update" do
    let!(:invoice) { Factory(:invoice) }
    
    before do
      login_as(:admin)
    end
    
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
      login_as(:admin)
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
