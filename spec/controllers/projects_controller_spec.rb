require 'spec_helper'

include SharedMethods

describe ProjectsController do
  describe "index" do
    let!(:activity) { Factory(:activity) }
    let(:project) { activity.project }
    let(:user) { activity.user }
    
    context "html" do
      before { get :index }
      
      it_should_behave_like "new resource", :project
      it_should_behave_like "render template", :index
      it_should_behave_like "list of", :projects, [:project]
    end
    
    context "json" do
      let!(:other_activity) { Factory(:activity) }
      let(:other_project) { other_activity.project }
      
      context "with user specified" do
        before { get :index, :user_id => user.id, :format => :json }
        
        it_should_behave_like "list of", :projects, [:project]
        it_should_behave_like "render json", /\[(.*)\]/
      end
      
      context "without user specified" do
        before { get :index, :format => :json }
        
        it_should_behave_like "list of", :projects, [:project, :other_project]
        it_should_behave_like "render json", /\[(.*)\]/
      end
    end
  end
  
  describe "new" do
    before do
      login_as(:admin)
      
      get :new
    end
    
    it_should_behave_like "new resource", :project
    it_should_behave_like "render template", :form
  end
  
  describe "create" do
    let!(:user) { Factory(:admin) }
    let!(:client) { Factory(:client) }
    let!(:count) { Project.count }
    
    before { login_as(user) }
    
    context "with valid data" do
      before do
        get :create, :project => {
          :name => 'my project', 
          :client_id => client.id,
          :active => '1'
        }
      end
      
      it "should create project" do
        Project.count.should eql(count + 1)
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "redirection", :projects
    end
    
    context "with invalid data" do
      before { get :create, :project => {} }
      
      it "should not create project" do
        Project.count.should eql(count)
      end
      
      it_should_behave_like "flash error"
      it_should_behave_like "render template", :index
      it_should_behave_like "new resource", :project
      it_should_behave_like "list of", :projects
    end
  end
  
  describe "edit" do
    let!(:hourly_rate) { Factory(:hourly_rate) }
    let(:project) { hourly_rate.project }
    let(:hourly_rates) { [hourly_rate] }
    
    before do
      login_as(:admin)
      
      get :edit, :id => project.id
    end
    
    it_should_behave_like "render template", :form
    it_should_behave_like "variable", :project
    it_should_behave_like "variable", :hourly_rates
  end
  
  describe "update" do
    let!(:project) { Factory(:project) }
    
    before { login_as(:admin) }
    
    context "with valid data" do
      let(:name) { 'Project X' }
      
      before do
        put :update, :id => project.id, :project => {:name => name}
      end
      
      it "should update project data" do
        project.reload.name.should eql(name)
      end
      
      it_should_behave_like "flash info"
      it_should_behave_like "redirection", :projects
    end
    
    context "with invalid data" do
      let!(:old_name) { project.name }
      
      before do
        put :update, :id => project.id, :project => {:name => ''}
      end
      
      it "should not update project data" do
        project.reload.name.should eql(old_name)
      end
      
      it_should_behave_like "flash error"
      it_should_behave_like "list of", :projects, [:project]
      it_should_behave_like "render template", :index
    end
  end
  
  describe "destroy" do
    render_views
    
    let!(:project) { Factory(:project) }
    
    before do
      login_as(:admin)
      delete :destroy, :id => project.id
    end
    
    it "should delete invoice" do
      expect {project.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end
    
    it "should response with valid json" do
      result = response.body
      
      match = result.match(/{"html":"(.*)","success":true}/)
      html = match[1]
      
      match.should_not be_nil
      html.should_not =~ /<td>#{project.name}<\/td>/
      html.should include('No projects found')
    end
  end
end
