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
  describe "permissions" do
    before do
      get :calendar
    end
    
    it "should store location"do
      session[:return_to].should_not be_blank
    end
    
    it_should_behave_like "flash error"
    it_should_behave_like "root redirection"
  end
  
  describe "index" do
    context "when not logged in" do
      before do
        get :index
      end
      
      it_should_behave_like "login page redirection"
    end
    
    context "when logged in" do
      before { login_as(user) }
      
      context "as a regular user" do
        let!(:activity) { Factory(:activity) }
        let!(:user) { activity.user }
        
        before do
          get :index
        end
        
        it "should set @projects" do
          var = assigns(:projects)
          var.size.should eql(1)
          var.should include(activity.project)
        end
        
        it_should_behave_like "filter", ActivityFilter, [:user_id]
        it_should_behave_like "nil", :users
        it_should_behave_like "nil", :clients
        it_should_behave_like "render template", :index
      end
      
      context "as admin user" do
        let!(:user) { Factory(:admin) }
        let!(:other_admin) { Factory(:admin) }
        let!(:employee) { Factory(:user) }
        let!(:project) { Factory(:project) }
        let(:client) { project.client }
        
        before do
          get :index
        end
        
        it_should_behave_like "filter", ActivityFilter
        it_should_behave_like "list of", :projects, [:project]
        it_should_behave_like "list of", :users, [:user, :other_admin, :employee], ActiveRecord::Relation
        it_should_behave_like "list of", :clients, [:client]
      end
      
      context "as client user" do
        let!(:project) { Factory(:project) }
        let!(:activity) { Factory(:activity, :project => project) }
        let!(:other_activity) { Factory(:activity) }
        let!(:user) { Factory(:client_user, :client => project.client) }
        let(:activity_user) { activity.user }
        
        before { get :index }
        
        it_should_behave_like "filter", ActivityFilter, [:client_id, :project_id] 
        
        it "set filter fields" do
          var = assigns(:filter)
          var.client_id.should eql(user.client.id)
          var.project_id.should be_nil
        end
        
        it_should_behave_like "list of", :projects, [:project]
        it_should_behave_like "list of", :users, [:activity_user]
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
    let!(:activity) { Factory(:activity) }
    let!(:other_activity) { Factory(:activity) }
    
    context "regular user" do
      let!(:user) { activity.user }
      
      before { login_as(user) }
      
      context "when searching by my project" do
        before { post :search, :filter => {:project_id => activity.project.id} }
        
        it_should_behave_like "list of", :activities, [:activity]
      end
      
      context "when searching by others project" do
        before { post :search, :filter => {:project_id => other_activity.project.id} }
        
        it_should_behave_like "empty list", :activities
      end
    end
    
    context "client user" do
      let!(:user) { Factory(:client_user, :client => activity.project.client) }
      
      before { login_as(user) }
      
      context "when searching by my project" do
        before { post :search, :filter => {:project_id => activity.project.id} }
        
        it_should_behave_like "list of", :activities, [:activity]
      end
      
      context "when searching by others project" do
        before { post :search, :filter => {:project_id => other_activity.project.id} }
        
        it_should_behave_like "empty list", :activities
      end
    end
    
    context "admin user" do
      let!(:user) { Factory(:admin) }
      
      before { login_as(user) }
      
      context "when searching by my project" do
        before { post :search, :filter => {:project_id => activity.project.id} }
        
        it_should_behave_like "list of", :activities, [:activity]
      end
      
      context "when searching by others project" do
        before { post :search, :filter => {:project_id => other_activity.project.id} }
        
        it_should_behave_like "list of", :activities, [:other_activity]
      end
      
      context "when searching by any project" do
        before { post :search, :filter => {} }
        
        it_should_behave_like "list of", :activities, [:activity, :other_activity]
      end
    end
  end
  
  describe "calendar" do
    context "get" do
      context "for admin user" do
        let!(:user) { Factory(:admin) }
        let!(:employee_1) { Factory(:user) }
        let!(:employee_2) { Factory(:user) }
        let!(:activity) { Factory(:activity, :user => user, :date => Date.current) }
        
        before do 
          login_as(user)
          
          get :calendar
        end
        
        it "should set current user as @user" do
          assigns(:user).should eql(subject.current_user)
        end
        
        it "should set all employees as @users" do
          var = assigns(:users)
          var.size.should eql(3)
          var.should include(user, employee_1, employee_2)
        end
        
        it "should set my activities as @activities" do
          var = assigns(:activities)
          var.size.should eql(1)
          var.should include(activity)
        end
        
        it_should_behave_like "render template", :calendar
      end
      
      context "for client user" do
        let!(:user) { Factory(:client_user) }
        
        before { login_as(user) }
        
        context "with no collaborators" do
          before { get :calendar }
          
          it "should set nil as @user" do
            assigns(:user).should be_nil 
          end
          
          it "should set empty collection as @users" do
            assigns(:users).should be_empty
          end
          
          it "should set empty collection as @activities" do
            assigns(:activities).should be_empty
          end
        end
        
        context "with any collaborators" do
          let!(:employee_1) { Factory(:user) }
          let!(:employee_2) { Factory(:user) }
          let!(:project) { Factory(:project, :client => user.client) }
          let!(:activity_1) { Factory(:activity, :user => employee_1, :project => project, :date => Date.current) }
          let!(:activity_2) { Factory(:activity, :user => employee_2, :project => project, :date => Date.current) }
          
          before { get :calendar }
          
          it_should_behave_like "variable", :user, :employee_1
          it_should_behave_like "list of", :users, [:employee_1, :employee_2]
          it_should_behave_like "list of", :activities, [:activity_1], ActiveRecord::Relation
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
        
        it_should_behave_like "list of", :users, [:user]
        it_should_behave_like "list of", :activities, [:activity], ActiveRecord::Relation
        
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
        let!(:user) { Factory(:admin) }
        let!(:activity) { Factory(:activity, :date => Date.current) }
        let!(:employee) { activity.user }
        
        before { login_as(user) }
        
        context "when requested user exists" do
          before { post :calendar, :user_id => employee.id }
          
          it_should_behave_like "variable", :user, :employee
          it_should_behave_like "list of", :activities, [:activity], ActiveRecord::Relation
        end
        
        context "when requested user does not exists" do
          before { post :calendar, :user_id => 'xxx' }
          
          it_should_behave_like "nil", :user
          it_should_behave_like "empty list", :activities
        end
      end
      
      context "for client user" do
        let!(:user) { Factory(:client_user) }
        let!(:my_employee) { Factory(:user) }
        let!(:other_employee) { Factory(:user) }
        let!(:project) { Factory(:project, :client => user.client) }
        let!(:activity_1) { Factory(:activity, :user => my_employee, :project => project, :date => Date.current) }
        let!(:activity_2) { Factory(:activity, :user => other_employee, :date => Date.current) }
        
        before { login_as(user) }
        
        context "when requested user is client's collaborator" do
          before { post :calendar, :user_id => my_employee.id }
          
          it_should_behave_like "variable", :user, :my_employee
          it_should_behave_like "list of", :users, [:my_employee]
          it_should_behave_like "list of", :activities, [:activity_1], ActiveRecord::Relation
        end
        
        context "when requested user is not client's collaborator" do
          before { post :calendar, :user_id => other_employee.id }
          
          it_should_behave_like "nil", :user
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
      
      it_should_behave_like "list of", :users, [:admin, :employee], ActiveRecord::Relation
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
        before { post :search_missed, :filter => {:user_id => my_employee.id} }
        
        it "should set filter.user_id" do
          assigns(:filter).user_id.should eql(my_employee.id)
        end
        
        it_should_behave_like "render template", "activities/missed/_results"
        it_should_behave_like "filter", MissedActivityFilter, [:user_id]
      end
      
      context "when user_id is not valid" do
        before { post :search_missed, :filter => {:user_id => other_employee.id} }
        
        it "should nullify filter.user_id" do
          assigns(:filter).user_id.should be_nil
        end
        
        it_should_behave_like "filter", MissedActivityFilter
      end
    end
    
    context "for regular user" do
      let!(:user) { Factory(:user) }
      let!(:other_user) { Factory(:user) }
      
      before { login_as(user) }
      
      context "when user_id is valid" do
        before { post :search_missed, :filter => {:user_id => user.id} }
        
        it "should set filter.user_id" do
          assigns(:filter).user_id.should eql(user.id)
        end
        
        it_should_behave_like "render template", "activities/missed/_results"
        it_should_behave_like "filter", MissedActivityFilter, [:user_id]
      end
      
      context "when user_id is not valid" do
        before { post :search_missed, :filter => {:user_id => other_user.id} }
        
        it "should set filter.user_id as loggen in user's id" do
          assigns(:filter).user_id.should eql(user.id)
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
      it_should_behave_like "variable", :activity
    end
    
    context "for regular user" do
      before { login_as(activity.user) }
      
      context "his activity" do
        before { get :edit, :id => activity.id }
        
        it_should_behave_like "render template", "_form"
        it_should_behave_like "variable", :activity
      end
      
      context "other user's activity" do
        let!(:other_activity) { Factory(:activity) }
        
        before { get :edit, :id => other_activity.id }
        
        it "should render nothing" do
          response.body.should be_blank
        end
      end
    end
  end
  
  describe "create" do
    let!(:project) { Factory(:project) }
    let!(:user) { Factory(:user) }
    let!(:count) { Activity.count }
    let(:activity_data) do
      {:project_id => project.id, 
        :user_id => user.id, 
        :comments => 'Working on authentication', 
        :date => '2011-01-19',
        :time_spent => '6:45'
      }
    end
    
    context "for admin user" do
      before do
        login_as(:admin)
        
        post :create, :activity => activity_data
      end
      
      it "should create activity" do
        Activity.count.should eql(count + 1)
      end
      
      it "should render json" do
        result = response.body
        match = result.match(/{"success":true,"activity":{(.*)}}/)
        match.should_not be_nil
        
        json = match[1]
        match = json.match(/"id":(.*)/)
        match.should_not be_nil
      end
    end
    
    context "for regular user" do
      before { login_as(user) }
      
      context "his activity" do
        context "valid data" do
          before { post :create, :activity => activity_data }
          
          it "should create activity" do
            Activity.count.should eql(count + 1)
          end
        end
        
        context "invalid data" do
          before do
            activity_data.delete(:comments)
            
            post :create, :activity => activity_data
          end
          
          it "should not create activity" do
            Activity.count.should eql(count)
          end
          
          it "should render json" do
            result = response.body
            match = result.match(/{"success":false,"html":"(.*)"}/)
            match.should_not be_nil
          end
        end
      end
      
      context "other user's activity" do
        let!(:other_user) { Factory(:user) }
        
        before do
          activity_data[:user_id] = other_user.id
          
          post :create, :activity => activity_data
        end
        
        it "should create activity" do
          Activity.count.should eql(count + 1)
        end
        
        it "should assign current user to this activity" do
          assigns(:activity).user eql(user)
        end
      end
    end
  end
  
  describe "update" do
    let!(:activity) { Factory(:activity) }
    let!(:old_date) { activity.date.to_date }
    let(:new_date) { old_date.ago(1.day).to_date }
    
    context "for admin user" do
      before do
        login_as(:admin)
        
        put :update, :id => activity.id, :activity => {:date => new_date}
      end
      
      it "should update activity" do
        activity.reload.date.should eql(new_date)
      end
      
      it "should render json" do
        result = response.body
        match = result.match(/{"success":true,"activity":{(.*)}}/)
        match.should_not be_nil
        
        json = match[1]
        json.should =~ /"id":#{activity.id}/
      end
    end
    
    context "for regular user" do
      before { login_as(activity.user) }
      
      context "his activity" do
        context "valid data" do
          before { put :update, :id => activity.id, :activity => {:date => new_date} }
          
          it "should update activity" do
            activity.reload.date.should eql(new_date)
          end
        end
        
        context "invalid data" do
          before { put :update, :id => activity.id, :activity => {:comments => ''} }
          
          it "should not update activity" do
            activity.reload.date.should eql(old_date)
          end
          
          it "should render json" do
            result = response.body
            match = result.match(/{"success":false,"html":"(.*)"}/)
            match.should_not be_nil
          end
        end
      end
      
      context "other user's activity" do
        let!(:other_activity) { Factory(:activity) }
        
        before do
          login_as(activity.user)
          
          put :update, :id => other_activity.id, :activity => {:date => new_date}
        end
        
        it "should not update activity" do
          activity.reload.date.should eql(old_date)
        end
        
        it "should render json" do
          result = response.body
          match = result.match(/{"success":false,"html":"(.*)"}/)
          match.should_not be_nil
        end
      end
    end
  end
  
  describe "destroy" do
    let!(:activity) { Factory(:activity) }
    
    context "for admin user" do
      before do
        login_as(:admin)
        
        delete :destroy, :id => activity.id
      end
      
      it "should delete activity" do
        expect {activity.reload}.to raise_error(ActiveRecord::RecordNotFound)
      end
      
      it "should render json" do
        result = response.body
        match = result.match(/{"success":true,"activity":{(.*)}}/)
        match.should_not be_nil
        
        json = match[1]
        match = json.match(/"id":#{activity.id}/)
        match.should_not be_nil
      end
    end
    
    context "for regular user" do
      before { login_as(activity.user) }
      
      context "his activity" do
        before { delete :destroy, :id => activity.id }
        
        it "should delete activity" do
          expect {activity.reload}.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
      
      context "other user's activity" do
        let!(:other_activity) { Factory(:activity) }
        
        before { delete :destroy, :id => other_activity.id }
        
        it "should not delete activity" do
          expect {activity.reload}.to_not raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
  
  describe "invoice" do
    let!(:activity) { Factory(:activity) }
    let!(:client) { activity.project.client }
    let!(:other_activity) { Factory(:activity) }
    let(:ids) { [activity.id] }
    let(:name) { 'my invoice' }
    
    before { login_as(:admin) }
    
    context "with hourly rate not defined" do
      let!(:count) { Invoice.count }
      
      before { post :invoice, :activity_ids => ids, :invoice_name => name }
      
      it "should not create new invoice" do
        Invoice.count.should eql(count)
      end
      
      it "should render json" do
        response.body.match(/"success":false,"error":"(.*)","bad_activities":\[#{activity.id}\]/).should_not be_nil
      end
    end
    
    context "with hourly rate defined" do
      let!(:hourly_rate) { Factory(:hourly_rate, :project => activity.project) }
      
      context "new" do
        let!(:count) { Invoice.count }
        
        before { post :invoice, :activity_ids => ids, :invoice_name => name }
        
        context "with activities belonging to one client" do
          it "should create new invoice" do
            Invoice.count.should eql(count + 1)
          end
          
          it_should_behave_like "render json", /{"success":true}/
          
          it "should update activities" do
            activity.reload
            activity.invoice.should eql(assigns(:invoice))
            activity.invoiced_at.should eql(Date.current)
            activity.value.should eql(hourly_rate.value)
            activity.currency.should eql(hourly_rate.currency)
          end
        end
        
        context "with activities belonging to many clients" do
          let(:ids) { [activity.id, other_activity.id] }
          
          it "should not create new invoice" do
            Invoice.count.should eql(count)
          end
          
          it_should_behave_like "render json", /{"success":false,"error":"(.*)"}/
        end
      end
      
      context "existing" do
        let!(:invoice) { Factory(:invoice) }
        let!(:count) { Invoice.count }
        
        before { post :invoice, :activity_ids => ids, :invoice_id => invoice.id }
        
        it "should not create new invoice" do
          Invoice.count.should eql(count)
        end
        
        it_should_behave_like "render json", /{"success":true}/
      end
      
      context "when not determined whether to create or update invoice" do
        let!(:count) { Invoice.count }
        
        before { post :invoice, :activity_ids => ids }
        
        it "should not create new invoice" do
          Invoice.count.should eql(count)
        end
        
        it_should_behave_like "render json", /"success":false,"error":"(.*)"/
      end
    end
  end
  
  describe "day_off" do
    let(:date) { Date.current.to_s(:db) }
    let!(:other_user) { Factory(:user) }
    let!(:count) { FreeDay.count }
    
    context "admin" do
      let!(:user) { Factory(:admin) }
      
      before do
        login_as(user)
        
        post :day_off, :date => date, :user_id => other_user.id
      end
      
      it "should create free day" do
        FreeDay.count.should eql(count + 1)
      end
      
      it "should assign free day to requested user" do
        assigns(:free_day).user.should eql(other_user)
      end
      
      it "should render json" do
        response.body.match(/{"date":"#{date}"}/).should_not be_nil
      end
    end
    
    context "regular user" do
      let!(:user) { Factory(:user) }
      
      before { login_as(user) }
      
      context "for other user" do
        before { post :day_off, :date => date, :user_id => other_user.id }
        
        it "should create free day" do
          FreeDay.count.should eql(count + 1)
        end
      
        it "should assign free day to current user" do
          assigns(:free_day).user.should eql(user)
        end
        
        it "should render json" do
          response.body.match(/{"date":"#{date}"}/).should_not be_nil
        end
      end
      
      context "without specifying user" do
        before { post :day_off, :date => date }
        
        it "should create free day" do
          FreeDay.count.should eql(count + 1)
        end
      
        it "should assign free day to current user" do
          assigns(:free_day).user.should eql(user)
        end
        
        it "should render json" do
          response.body.match(/{"date":"#{date}"}/).should_not be_nil
        end
      end
    end
  end
  
  describe "revert_day_off" do
    let!(:free_day) { Factory(:free_day) }
    
    context "admin" do
      let!(:user) { Factory(:admin) }
      let(:date) { free_day.date.to_s(:db) }
      
      before do
        login_as(user)
        
        post :revert_day_off, :date => date, :user_id => free_day.user.id
      end
      
      it "should delete free day" do
        expect {free_day.reload}.to raise_error(ActiveRecord::RecordNotFound)
      end
      
      it "should render json" do
        response.body.match(/{"date":"#{date}"}/).should_not be_nil
      end
    end
    
    context "regular user" do
      let!(:my_free_day) { Factory(:free_day) }
      let!(:count) { FreeDay.count }
      let!(:user) { my_free_day.user }
      let!(:my_count) { user.free_days.count }
      let(:date) { my_free_day.date.to_date.to_s(:db) }
      
      before { login_as(user) }
      
      context "for other user" do
        before { post :revert_day_off, :date => date, :user_id => free_day.user.id }
        
        it "should delete free day" do
          expect {my_free_day.reload}.to raise_error(ActiveRecord::RecordNotFound)
        end
        
        it "should render json" do
          response.body.match(/{"date":"#{date}"}/).should_not be_nil
        end
      end
      
      context "without specifying user" do
        before { post :revert_day_off, :date => date }
        
        it "should delete free day" do
          expect {my_free_day.reload}.to raise_error(ActiveRecord::RecordNotFound)
        end
        
        it "should render json" do
          response.body.match(/{"date":"#{date}"}/).should_not be_nil
        end
      end
    end
  end
end
