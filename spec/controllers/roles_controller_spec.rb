require 'spec_helper'

include SharedMethods

describe RolesController do
  before { login_as(:admin) }
  
  describe "index" do
    let!(:role) { Factory(:developer) }
    
    before do
      get :index
    end
    
    it_should_behave_like "new resource", :role
    it_should_behave_like "render template", :index
    it_should_behave_like "list of", :roles, [:role]
  end
  
  describe "new" do
    before do
      get :new
    end
    
    it_should_behave_like "new resource", :role
    it_should_behave_like "render template", :form
  end
  
  describe "create" do
    let!(:count) { Role.count }
    
    context "with valid data" do
      before do
        get :create, :role => {
          :name => 'tester', 
          :can_manage_financial_data => 0
        }
      end
      
      it "should create role" do
        Role.count.should eql(count + 1)
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "redirection", :roles
    end
    
    context "with invalid data" do
      before do
        get :create, :role => {}
      end
      
      it "should not create role" do
        Role.count.should eql(count)
      end
      
      it_should_behave_like "flash error"
      it_should_behave_like "render template", :index
      it_should_behave_like "new resource", :role
      it_should_behave_like "list of", :roles
    end
  end
  
  describe "edit" do
    let!(:role) { Factory(:developer) }
    
    before do
      get :edit, :id => role.id
    end
    
    it_should_behave_like "render template", :form
    it_should_behave_like "variable", :role
  end
  
  describe "update" do
    let!(:role) { Factory(:developer) }
    
    context "with valid data" do
      let(:name) { 'engineer' }
      
      before do
        put :update, :id => role.id, :role => {:name => name}
      end
      
      it "should update role data" do
        role.reload.name.should eql(name)
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "redirection", :roles
    end
    
    context "with invalid data" do
      let!(:old_name) { role.name }
      
      before do
        put :update, :id => role.id, :role => {:name => ''}
      end
      
      it "should not update role data" do
        role.reload.name.should eql(old_name)
      end
      
      it_should_behave_like "flash error"
      it_should_behave_like "list of", :roles, [:role]
      it_should_behave_like "render template", :index
    end
  end
  
  describe "destroy" do
    render_views
    
    let!(:role) { Factory(:developer) }
    
    before do
      delete :destroy, :id => role.id
    end
    
    it "should delete role" do
      expect {role.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end
    
    it "should response with valid json" do
      result = response.body
      
      match = result.match(/{"html":"(.*)","success":true}/)
      html = match[1]
      
      match.should_not be_nil
      html.should_not =~ /<td>#{role.name}<\/td>/
      html.should include('No roles found')
    end
  end
end
