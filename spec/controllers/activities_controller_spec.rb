require 'spec_helper'

include SharedMethods

shared_examples_for "filter" do |klass, skip = []|
  it "should set filter" do
    var = assigns(:filter)
    var.should be_instance_of(klass)
    (klass::FIELDS - skip).all? {|i| var.send(i).blank?}.should be_true
  end
end

describe ActivitiesController do
  describe "index" do
    context "when not logged in" do
      before do
        get :index
      end
      
      it_should_behave_like "login page redirection"
    end
    
    context "when logged in" do
      context "as a regular user" do
        let!(:activity) { Factory(:activity) }
        let!(:user) { activity.user }
        
        before do
          login_as(user)
          
          get :index
        end
        
        it "should set @projects" do
          var = assigns(:projects)
          var.size.should eql(1)
          var.should include(activity.project)
        end
        
        it_should_behave_like "filter", ActivityFilter, [:user_id]
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
          login_as(user)
          
          get :index
        end
        
        it_should_behave_like "filter", ActivityFilter
        
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
          login_as(client_user)
          
          get :index
        end
        
        it_should_behave_like "filter", ActivityFilter, [:client_id, :project_id] 
        
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
    
    context "regular user" do
      before { login_as(my_activity.user) }
      
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
      
      before { login_as(client_user) }
      
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
  
  describe "calendar" do
    context "get" do
      context "for admin user" do
        let!(:admin) { Factory(:admin) }
        let!(:employee_1) { Factory(:user) }
        let!(:employee_2) { Factory(:user) }
        let!(:my_activity) { Factory(:activity, :user => admin, :date => Date.current) }
        
        before do
          login_as(admin)
          
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
        let!(:client_user) { Factory(:client_user) }
        
        context "with no collaborators" do
          before do
            login_as(client_user)
          
            get :calendar
          end
          
          it "should set first collaborator as @user" do
            assigns(:user).should be_nil 
          end
          
          it "should set empty collection as @users" do
            assigns(:users).should be_empty
          end
          
          it "should set user activities as @activities" do
            assigns(:activities).should be_empty
          end
        end
        
        context "with any collaborators" do
          let!(:employee_1) { Factory(:user) }
          let!(:employee_2) { Factory(:user) }
          let!(:project) { Factory(:project, :client => client_user.client) }
          let!(:activity_1) { Factory(:activity, :user => employee_1, :project => project, :date => Date.current) }
          let!(:activity_2) { Factory(:activity, :user => employee_2, :project => project, :date => Date.current) }
        
          before do
            login_as(client_user)
          
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
        end
      end
      
      context "for regular user" do
        let!(:user) { Factory(:user) }
        let!(:activity) { Factory(:activity, :user => user, :date => '2011-05-17') }
        let!(:free_day) { Factory(:free_day, :date => '2011-05-16', :user => user) }
        
        before do
          login_as(user)
          
          get :calendar
        end
        
        it "should set current user as @user" do
          assigns(:user).should eql(subject.current_user) 
        end
        
        it "should set collection with only this user as @users" do
          var = assigns(:users)
          var.size.should eql(1)
          var.should include(user)
        end
        
        it "should set user activities as @activities" do
          var = assigns(:activities)
          var.size.should eql(1)
          var.should include(activity)
        end
        
        it "should set @days_off_hash" do
          var = assigns(:days_off_hash)
          var[free_day.date].should eql(free_day)
        end
        
        it "should set @date" do
          assigns(:date).should eql(Date.current)
        end
        
        it "should set @first_day" do
          assigns(:first_day).should eql(Date.current.beginning_of_month)
        end
        
        it "should set calendat params" do
          assigns(:rows).should eql(6)
          assigns(:k0).should eql(6)
        end
      end
    end
    
    context "post" do
      context "for admin user" do
        let!(:admin) { Factory(:admin) }
        let!(:activity) { Factory(:activity, :date => Date.current) }
        let!(:employee) { activity.user }
        
        context "when requested user exists" do
          before do
            login_as(admin)
          
            post :calendar, :user_id => employee.id
          end
        
          it "should set requested user as @user" do
            assigns(:user).should eql(employee)
          end
        
          it "should set user's activities as @activities" do
            var = assigns(:activities)
            var.size.should eql(1)
            var.should include(activity)
          end
        end
        
        context "when requested user does not exists" do
          before do
            login_as(admin)
          
            post :calendar, :user_id => 'xxx'
          end
        
          it "should set nil as @user" do
            assigns(:user).should be_nil
          end
        
          it "should set empty collection as @activities" do
            assigns(:activities).should be_empty
          end
        end
      end
      
      context "for client user" do
        let!(:client_user) { Factory(:client_user) }
        let!(:my_employee) { Factory(:user) }
        let!(:other_employee) { Factory(:user) }
        let!(:project) { Factory(:project, :client => client_user.client) }
        let!(:activity_1) { Factory(:activity, :user => my_employee, :project => project, :date => Date.current) }
        let!(:activity_2) { Factory(:activity, :user => other_employee, :date => Date.current) }
        
        context "when requested user is client's collaborator" do
          before do
            login_as(client_user)
            
            post :calendar, :user_id => my_employee.id
          end
          
          it "should set my_employee as @user" do
            assigns(:user).should eql(my_employee)
          end
          
          it "should set all collaborators as @users" do
            var = assigns(:users)
            var.size.should eql(1)
            var.should include(my_employee)
          end
          
          it "should set user activities as @activities" do
            var = assigns(:activities)
            var.size.should eql(1)
            var.should include(activity_1)
          end
        end
        
        context "when requested user is not client's collaborator" do
          before do
            login_as(client_user)
          
            post :calendar, :user_id => other_employee.id
          end
          
          it "should set nil as @user" do
            assigns(:user).should be_nil
          end
        end
      end
    end
  end
  
  describe "missed" do
    context "for regular user" do
      before do
        login_as(:user)
        
        get :missed
      end
      
      it_should_behave_like "filter", MissedActivityFilter, [:user_id]
      it_should_behave_like "render template", :missed
    end
    
    context "for admin user" do
      let!(:admin) { Factory(:admin) }
      let!(:employee) { Factory(:user) }
      
      before do
        login_as(admin)
        
        get :missed
      end
      
      it "should set all employees as @users" do
        var = assigns(:users)
        var.size.should eql(2)
        var.should include(admin, employee)
      end
      
      it_should_behave_like "filter", MissedActivityFilter
    end
    
    context "for client user" do
      let!(:project) { Factory(:project) }
      let!(:activity) { Factory(:activity, :project => project) }
      let!(:other_activity) { Factory(:activity) }
      let!(:client_user) { Factory(:client_user, :client => project.client) }
      
      before do
        login_as(client_user)
        
        get :missed
      end
      
      it "should set all collaborators as @users" do
        var = assigns(:users)
        var.size.should eql(1)
        var.should include(activity.user)
      end
      
      it_should_behave_like "filter", MissedActivityFilter
    end
  end

  describe "search_missed" do
    context "for admin" do
      before do
        login_as(:admin)
        
        post :search_missed, :filter => {}
      end
      
      it_should_behave_like "render template", "activities/missed/_results"
      it_should_behave_like "filter", MissedActivityFilter
    end
    
    context "for client user" do
      let!(:client_user) { Factory(:client_user) }
      let!(:my_employee) { Factory(:user) }
      let!(:other_employee) { Factory(:user) }
      let!(:project) { Factory(:project, :client => client_user.client) }
      let!(:activity_1) { Factory(:activity, :user => my_employee, :project => project) }
      let!(:activity_2) { Factory(:activity, :user => other_employee) }
      
      before { login_as(client_user) }
      
      context "when user_id is valid" do
        before do
          post :search_missed, :filter => {:user_id => my_employee.id}
        end
        
        it "should set filter.user_id" do
          assigns(:filter).user_id.should eql(my_employee.id)
        end
        
        it_should_behave_like "render template", "activities/missed/_results"
        it_should_behave_like "filter", MissedActivityFilter, [:user_id]
      end
      
      context "when user_id is not valid" do
        before do
          post :search_missed, :filter => {:user_id => other_employee.id}
        end
        
        it "should nullify filter.user_id" do
          assigns(:filter).user_id.should be_nil
        end
        
        it_should_behave_like "filter", MissedActivityFilter
      end
    end
    
    context "for regular user" do
      let!(:employee) { Factory(:user) }
      let!(:other_employee) { Factory(:user) }
      
      before { login_as(employee) }
      
      context "when user_id is valid" do
        before do
          post :search_missed, :filter => {:user_id => employee.id}
        end
        
        it "should set filter.user_id" do
          assigns(:filter).user_id.should eql(employee.id)
        end
        
        it_should_behave_like "render template", "activities/missed/_results"
        it_should_behave_like "filter", MissedActivityFilter, [:user_id]
      end
      
      context "when user_id is not valid" do
        before do
          post :search_missed, :filter => {:user_id => other_employee.id}
        end
        
        it "should set filter.user_id as loggen in user's id" do
          assigns(:filter).user_id.should eql(employee.id)
        end
        
        it_should_behave_like "filter", MissedActivityFilter, [:user_id]
      end
    end
  end
  
  describe "edit" do
    let!(:activity) { Factory(:activity) }
    
    context "for admin user" do
      before do
        login_as(:admin)
        
        get :edit, :id => activity.id
      end
      
      it_should_behave_like "render template", "_form"
      it_should_behave_like "existing resource", :activity
    end
    
    context "for regular user" do
      context "his activity" do
        before do
          login_as(activity.user)
          
          get :edit, :id => activity.id
        end
        
        it_should_behave_like "render template", "_form"
        it_should_behave_like "existing resource", :activity
      end
      
      context "other user's activity" do
        let!(:other_activity) { Factory(:activity) }
        
        before do
          login_as(activity.user)
          
          get :edit, :id => other_activity.id
        end
        
        it "should render nothing" do
          response.body.should be_blank
        end
      end
    end
  end

    describe "update" do
      let!(:activity) { Factory(:activity) }
      let(:date) { activity.date.ago(1.day).to_date }
      
      context "for admin user" do
        before do
          login_as(:admin)
          
          put :update, :id => activity.id, :activity => {:date => date}
        end
        
        it "should update activity" do
          activity.reload.date.should eql(date)
        end
        
        it "should render json" do
          result = response.body
          match = result.match(/{"success":true,"activity":{(.*)}}/)
          activity_json = match[1]
          
          match.should_not be_nil
          activity_json.should =~ /"id":#{activity.id}/
        end
      end
    
      context "for regular user" do
        context "his activity" do
          before do
            login_as(activity.user)
          
            get :edit, :id => activity.id
          end
        
          it_should_behave_like "render template", "_form"
          it_should_behave_like "existing resource", :activity
        end
      
        context "other user's activity" do
          let!(:other_activity) { Factory(:activity) }
        
          before do
            login_as(activity.user)
          
            get :edit, :id => other_activity.id
          end
        
          it "should render nothing" do
            response.body.should be_blank
          end
        end
      end
    end
end
