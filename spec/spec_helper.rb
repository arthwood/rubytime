require 'simplecov_helper' if ENV['rcov']

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
end

module SharedMethods
  # type {admin, editor, user}
  def login_as(user)
    subject.stub!(:current_user).and_return(user.is_a?(Symbol) ? Factory(user) : user)
  end
end

shared_examples_for "flash info" do
  it "should set flash[:info]" do
    flash[:info].should_not be_blank
  end
end

shared_examples_for "flash error" do
  it "should set flash[:error]" do
    flash[:error].should_not be_blank
  end
end

shared_examples_for "render template" do |type|
  it "should render #{type}" do
    response.should render_template(type)
  end
end

shared_examples_for "render json" do |json|
  it "should render json" do
    response.body.match(json).should_not be_nil
  end
end

shared_examples_for "new resource" do |type|
  it "should set @#{type} variable" do
    var = assigns(type)
    var.should be_an_instance_of(type.to_s.camelize.constantize)
    var.should be_new_record
  end
end

shared_examples_for "variable" do |type, resource = nil|
  it "should set proper @#{type} variable" do
    assigns(type).should eql(method(resource || type).call)
  end
end

shared_examples_for "nil" do |type|
  it "should set nil as @#{type} variable" do
    assigns(type).should be_nil
  end
end

shared_examples_for "empty list" do |type, coll_type = Array|
  it "@#{type}" do
    var = assigns(type)
    var.should be_an_instance_of(coll_type)
    var.should be_empty
  end
end

shared_examples_for "list of" do |type, resources = nil, coll_type = Array|
  it "@#{type}" do
    var = assigns(type)
    var.should be_an_instance_of(coll_type)
    
    if resources.present?
      var.size.should eql(resources.size)
      var.should include(*(resources.map {|i| method(i).call}))
    end
  end
end

shared_examples_for "redirection" do |type|
  it "should redirect to #{type}" do
    response.should redirect_to(type)
  end
end

shared_examples_for "root redirection" do
  it "should redirect to root" do
    response.should redirect_to(root_url)
  end
end

shared_examples_for "login page redirection" do
  it "should redirect to login page" do
    response.should redirect_to(login_url)
  end
end

shared_examples_for "success" do
  it "should respond with success" do
    response.should be_success
  end
end
