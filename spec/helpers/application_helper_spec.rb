require 'spec_helper'

include SharedMethods

shared_examples_for "render js_env" do |editor|
  it "should render proper js code" do
    match = (js_env.delete("\n").match(/<script type="text\/javascript">\/\/<!\[CDATA\[(.*)\/\/\]\]><\/script>/))
    js = match[1]
    match.should_not be_nil
    match = js.match(/var env = {(.*)};/)
    env = match[1]
    env.should =~ /user: {editor: #{editor}}/
    env.should =~ /token: '#{token}'/
  end
end

describe ApplicationHelper do
  include RubytimeHelper
  
  describe "set_c_and_a" do
    let(:c) { 'activities' }
    let(:a) { 'index' }
    
    before do
      stub!(:params).and_return(:controller => c, :action => a)
      
      set_c_and_a
    end
    
    it "should assign @c and @a variables" do
      instance_variable_get(:@c).should eql(c)
      instance_variable_get(:@a).should eql(a)
    end
  end
  
  describe "js_env" do
    subject { self }
    
    let(:token) { 'token' }
    
    before do
      stub!(:form_authenticity_token).and_return(token)
    end
    
    context "when not logged in"do
      it_should_behave_like "render js_env", false
    end
    
    context "when logged in" do
      context "when not editor"do
        before { login_as(:client_user) }
        
        it_should_behave_like "render js_env", false
      end
      
      context "when editor"do
        before { login_as(:user) }
        
        it_should_behave_like "render js_env", true
      end
    end
  end
  
  describe "section" do
    context "manage" do
      before do
        instance_variable_set(:@c, 'projects')
      end
      
      it "should return proper value"do
        section.should eql(:manage)
      end
    end
    
    context "activities" do
      before do
        instance_variable_set(:@c, 'activities')
      end
      
      it "should return proper value"do
        section.should eql(:activities)
      end
    end
    
    context "invoices" do
      before do
        instance_variable_set(:@c, 'invoices')
      end
      
      it "should return proper value"do
        section.should eql(:invoices)
      end
    end
  end
  
  describe "menu_link" do
    context "with section selected" do
      before do
        stub!(:section).and_return(:activities)
      end
      
      it "should return proper link"do
        menu_link('activities', activities_url).should eql(
          %(<a href="http://test.host/activities" class="selected">activities</a>)
        )
      end
    end
    
    context "with section not selected" do
      before do
        stub!(:section).and_return(:invoices)
      end
      
      it "should return proper link"do
        menu_link('activities', activities_url).should eql(
          %(<a href="http://test.host/activities">activities</a>)
        )
      end
    end
  end
  
  describe "submenu_link" do
    context "with section selected" do
      before do
        stub!(:params).and_return(:controller => :activities, :action => :calendar)
      end
      
      it "should return proper link"do
        submenu_link('Calendar', calendar_activities_url).should eql(
          %(<a href="http://test.host/activities/calendar" class="selected">Calendar</a>)
        )
      end
    end
    
    context "with section not selected" do
      before do
        stub!(:params).and_return(:controller => :activities, :action => :index)
      end
      
      it "should return proper link"do
        submenu_link('Calendar', calendar_activities_url).should eql(
          %(<a href="http://test.host/activities/calendar">Calendar</a>)
        )
      end
    end
  end
   
  describe "verbalize" do
    context "when true is passed"do
      it "should return 'yes'" do
        verbalize(true).should eql('yes')
      end
    end
    
    context "when false is passed"do
      it "should return 'no'" do
        verbalize(false).should eql('no')
      end
    end
  end
  
  describe "error_field" do
    context "without errors" do
      let!(:project) { Factory.build(:project) }
      
      before { project.save }
      
      it "should return nil" do
        error_field(project, :client_id).should be_nil
      end
    end
    
    context "with errors" do
      let!(:project) { Factory.build(:project, :client_id => nil) }
      
      before { project.save }
      
      it "should return nil" do
        error_field(project, :client_id).should =~ /<div class="error">(.*)<\/div>/
      end
    end
  end
  
  describe "row_class" do
    context "even" do
      it "should return 'even'" do
        row_class(0).should eql('even')
      end
    end
    
    context "odd" do
      it "should return 'odd'" do
        row_class(1).should eql('odd')
      end
    end
  end
  
  describe "admin?" do
    subject { self }
    
    context "if admin" do
      before { login_as(:admin) }
      
      it { should be_admin }
    end
    
    context "if not admin" do
      context "if user" do
        before { login_as(:user) }
        
        it { should_not be_admin }
      end
      
      context "if client" do
        before { login_as(:client_user) }
        
        it { should_not be_admin }
      end
    end
  end

  describe "editor?" do
    subject { self }
    
    context "if user" do
      before { login_as(:user) }
      
      it { should be_editor }
    end
    
    context "if client" do
      before { login_as(:client_user) }
      
      it { should_not be_editor }
    end
  end

  describe "client?" do
    subject { self }
    
    context "if client" do
      before { login_as(:client_user) }
      
      it { should be_client }
    end
    
    context "if user" do
      before { login_as(:user) }
      
      it { should_not be_client }
    end
  end

  describe "admin_or_client?" do
    subject { self }
    
    context "if admin" do
      before { login_as(:admin) }
      
      it { should be_admin_or_client }
    end
    
    context "if client" do
      before { login_as(:client_user) }
      
      it { should be_admin_or_client }
    end
    
    context "if user" do
      before { login_as(:user) }
      
      it { should_not be_admin_or_client }
    end
  end
  
  describe "form_header" do
    context "new resource" do
      let!(:resource) { Factory.build(:project) }
      
      it "should return proper value" do
        form_header(resource).should eql("Add new project")
      end
    end
    
    context "existing resource" do
      let!(:resource) { Factory(:project) }
      
      it "should return proper value" do
        form_header(resource).should eql(%(Edit project <span>(or <a href="/projects/new">add new</a>)</span>))
      end
    end
  end
  
  describe "daterange_options" do
    before do
      Date.stub!(:current).and_return(Date.parse('2011/05/20'))
    end
    
    it "should render proper html" do
      result = daterange_options
      
      result.should include('<option value="2011-05-20/2011-05-20">Today (2011/05/20 - 2011/05/20)</option>')
      result.should include('<option value="2011-05-19/2011-05-19">Yesterday (2011/05/19 - 2011/05/19)</option>')
      result.should include('<option value="2011-05-16/2011-05-22">This Week (2011/05/16 - 2011/05/22)</option>')
      result.should include('<option value="2011-05-09/2011-05-15">Last Week (2011/05/09 - 2011/05/15)</option>')
      result.should include('<option value="2011-05-01/2011-05-31">This Month (2011/05/01 - 2011/05/31)</option>')
      result.should include('<option value="2011-04-01/2011-04-30">Last Month (2011/04/01 - 2011/04/30)</option>')
    end
  end
  
  
  describe "activity_field_id" do
    before do
      instance_variable_set(:@prefix, 'new')
    end
    
    it "should return proper value" do
      activity_field_id('comments').should eql('new_activity_comments')
    end
  end
  
  describe "day_off_tag" do
    it "should return proper tag" do
      day_off_tag.should =~ /<a href="\/activities\/day_off"><img alt="Day_off" src="\/images\/day_off\.png\?\d+" title="Day off" \/><\/a>/
    end
  end
  
  describe "revert_day_off_tag" do
    it "should return proper tag" do
      revert_day_off_tag.should =~ /<a href="\/activities\/revert_day_off" class="revert"><img alt="Revert_day_off" src="\/images\/revert_day_off\.png\?\d+" title="Revert day off" \/><\/a>/
    end
  end
end
