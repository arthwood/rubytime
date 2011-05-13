require 'spec_helper'

include SharedMethods

shared_examples_for "filter" do |skip = []|
  it "should set activity filter" do
    var = assigns(:filter)
    var.should be_instance_of(ActivityFilter)
    (%w(user_id project_id client_id period from to invoice_filter) - skip).all? {|i| var.send(i).blank?}.should be_true
  end
end

describe ActivitiesController do
=begin
  describe "index" do
    context "when not logged in" do
      before do
        get :index
      end
      
      it_should_behave_like "login page redirection"
    end
    
    context "when logged in" do
      context "as normal user" do
        let!(:activity) { Factory(:activity) }
        let!(:user) { activity.user }
        
        before do
          subject.stub!(:current_user).and_return(user)
          
          get :index
        end
        
        it "should set @projects" do
          var = assigns(:projects)
          var.size.should eql(1)
          var.should include(activity.project)
        end
        
        it_should_behave_like "filter"
        it_should_behave_like "not setting a variable", :users
        it_should_behave_like "not setting a variable", :clients
        it_should_behave_like "render template", :index
      end
      
      context "as admin user" do
        let!(:user) { Factory(:admin) }
        let!(:other_admin) { Factory(:admin) }
        let!(:employee) { Factory(:user) }
        let!(:project) { Factory(:project) }
        
        before do
          subject.stub!(:current_user).and_return(user)
          
          get :index
        end
        
        it_should_behave_like "filter"
        
        it "should set @projects" do
          var = assigns(:projects)
          var.size.should eql(1)
          var.should include(project)
        end
        
        it "should set @users" do
          var = assigns(:users)
          var.size.should eql(3)
          var.should include(user, other_admin, employee)
        end
        
        it "should set @clients" do
          var = assigns(:clients)
          var.size.should eql(1)
          var.should include(project.client)
        end
      end
      
      context "as client user" do
        let!(:project) { Factory(:project) }
        let!(:activity) { Factory(:activity, :project => project) }
        let!(:other_activity) { Factory(:activity) }
        let!(:client_user) { Factory(:client_user, :client => project.client) }
        
        before do
          subject.stub!(:current_user).and_return(client_user)
          
          get :index
        end
        
        it_should_behave_like "filter", %w(client_id project_id) 
        
        it "set filter fields" do
          var = assigns(:filter)
          var.client_id.should eql(client_user.client.id)
          var.project_id.should be_nil
        end
        
        it "should set @projects" do
          var = assigns(:projects)
          var.size.should eql(1)
          var.should include(project)
        end
        
        it "should set @users" do
          var = assigns(:users)
          var.size.should eql(1)
          var.should include(activity.user)
        end
      end
    end
  end
  
  describe "export" do
    let!(:activity_1) { Factory(:activity) }
    let!(:activity_2) { Factory(:activity) }
    
    before { login_as(:user) }
    
    context "to csv" do
      it "should render a file" do
        Activity.should_receive(:to_csv).with([activity_1, activity_2])
        get :export, :ids => [activity_1.id, activity_2.id], :format => 'csv'
      end
    end
    
    context "to pdf" do
      it "should render a file" do
        Activity.should_receive(:to_pdf).with([activity_1, activity_2], 'Activities', false)
        get :export, :ids => [activity_1.id, activity_2.id], :format => 'pdf'
      end
    end
  end

  describe "search" do
    let!(:my_activity) { Factory(:activity) }
    let!(:other_activity) { Factory(:activity) }
    
    context "normal user" do
      before { login_as(:user, my_activity.user) }
      
      context "when searching by my project" do
        before do
          post :search, :filter => {:project_id => my_activity.project.id}
        end
        
        it "should return my activities" do
          var = assigns(:activities)
          var.size.should eql(1)
          var.should include(my_activity)
        end
      end
      
      context "when searching by others project" do
        before do
          post :search, :filter => {:project_id => other_activity.project.id}
        end
        
        it "should not return any activities" do
          assigns(:activities).should be_empty
        end
      end
    end
    
    context "client user" do
      let!(:client_user) { Factory(:client_user, :client => my_activity.project.client) }
      
      before { login_as(:user, client_user) }
      
      context "when searching by my project" do
        before do
          post :search, :filter => {:project_id => my_activity.project.id}
        end
        
        it "should return my activities" do
          var = assigns(:activities)
          var.size.should eql(1)
          var.should include(my_activity)
        end
      end
      
      context "when searching by others project" do
        before do
          post :search, :filter => {:project_id => other_activity.project.id}
        end
        
        it "should not return any activities" do
          assigns(:activities).should be_empty
        end
      end
    end
    
    context "admin user" do
      before { login_as(:admin) }
      
      context "when searching by my project" do
        before do
          post :search, :filter => {:project_id => my_activity.project.id}
        end
        
        it "should return my activities" do
          var = assigns(:activities)
          var.size.should eql(1)
          var.should include(my_activity)
        end
      end
      
      context "when searching by others project" do
        before do
          post :search, :filter => {:project_id => other_activity.project.id}
        end
        
        it "should return other activities" do
          var = assigns(:activities)
          var.size.should eql(1)
          var.should include(other_activity)
        end
      end
      
      context "when searching by any project" do
        before do
          post :search, :filter => {}
        end
        
        it "should return all activities" do
          var = assigns(:activities)
          var.size.should eql(2)
          var.should include(my_activity, other_activity)
        end
      end
    end
  end
=end
  describe "calendar" do
    context "get" do
      context "for admin user" do
        let!(:admin) { Factory(:admin) }
        let!(:employee_1) { Factory(:user) }
        let!(:employee_2) { Factory(:user) }
        let!(:my_activity) { Factory(:activity, :user => admin, :date => Date.current) }
        
        before do
          login_as(:admin, admin)
          
          get :calendar
        end
        
        it "should set current user as @user" do
          assigns(:user).should eql(subject.current_user)
        end
        
        it "should set all employees as @users" do
          var = assigns(:users)
          var.size.should eql(3)
          var.should include(admin, employee_1, employee_2)
        end
        
        it "should set my activities as @activities" do
          var = assigns(:activities)
          var.size.should eql(1)
          var.should include(my_activity)
        end
        
        it_should_behave_like "render template", :calendar
      end
      
      context "for client user" do
        let!(:employee_1) { Factory(:user) }
        let!(:employee_2) { Factory(:user) }
        let!(:client_user) { Factory(:client_user) }
        let!(:project) { Factory(:project, :client => client_user.client) }
        let!(:activity_1) { Factory(:activity, :user => employee_1, :project => project, :date => Date.current) }
        let!(:activity_2) { Factory(:activity, :user => employee_2, :project => project, :date => Date.current) }
        
        before do
          login_as(:user, client_user)
          
          get :calendar
        end
        
        it "should set first collaborator as @user" do
          assigns(:user).should eql(employee_1) 
        end
        
        it "should set all collaborators as @users" do
          var = assigns(:users)
          var.size.should eql(2)
          var.should include(employee_1, employee_2)
        end
        
        it "should set user activities as @activities" do
          var = assigns(:activities)
          var.size.should eql(1)
          var.should include(activity_1)
        end
        
        it_should_behave_like "render template", :calendar
      end
    end
  end
end
