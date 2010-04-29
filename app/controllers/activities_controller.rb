class ActivitiesController < ApplicationController
  skip_before_filter :login_required, :only => :index
  
  before_filter :admin_required, :only => [:invoice]
  
  def index
    redirect_to login_url and return unless logged_in?
    set_filter
  end
  
  def search
    @params_filter = params[:activity_filter]
    
    set_filter
    
    @activities = Activity.search(@filter)
    
    if current_user.admin
      filter_client_id = @filter.client_id.to_i
      @client = @clients.detect {|i| i.id == filter_client_id}
      @invoices = @client && @client.invoices || Invoice.all
    end
    
    render :partial => 'results'
  end
  
  def calendar
    if current_user.admin
      @user = (user_id = params[:user_id]).blank? ? current_user : User.find(user_id)
    else
      @user = current_user
    end
    
    @activities = @user.activities
    @current = (current = params[:current]).blank? ? Date.current : Date.parse(current)
    @first_day = @current.at_beginning_of_month
    @rows = (@first_day.wday + @current.end_of_month.mday - 1) / 7
  end
  
  def edit
    set_activity
    
    if @found
      render :partial => 'form'
    else
      render :nothing => true
    end
  end
  
  def create
    data = params[:activity]
    
    data[:user_id] = current_user.id unless current_user.admin
    
    @activity = Activity.new(data)
    
    success = @activity.save
    
    json = {:success => success}
    
    if success
      render :json => json.merge(:activity => @activity)
    else
      render :json => json.merge(:html => render_to_string(:partial => 'form'))
    end
  end
  
  def update
    set_activity
    
    success = @found && @activity.update_attributes(params[:activity])
    
    json = {:success => success}
    
    if success
      render :json => json.merge(:activity => @activity.reload)
    else
      render :json => json.merge(:html => render_to_string(:partial => 'form'))
    end
  end

  def destroy
    set_activity
    
    @activity.destroy if @found
    
    render :json => @activity.to_json, :success => @found
  end
  
  def invoice
    @client = Client.find(params[:client_id])
    activity_ids = params[:activity_ids]
    # new invoice
    invoice_name = params[:invoice_name]
    # existing invoice
    invoice_id = params[:invoice_id]
    
    @activities = Activity.find(activity_ids)
    t = Date.current
    hourly_rates = HourlyRate.all(:order => 'date DESC')
    activity_and_hr = @activities.map do |i|
      {:activity => i, :hr => hourly_rates.detect {|j| 
        j.role_id == i.user.role_id && j.project_id == i.project_id && j.date <= t
      }}
    end
    
    bad_activities = activity_and_hr.select {|i| i[:hr].nil?}
    success = bad_activities.empty?
    json = {:success => success}
    
    if success
      @invoice = invoice_id.blank? \
        ? @client.invoices.create(:name => invoice_name, :user_id => current_user) \
        : Invoice.find(invoice_id)
      invoice_id = @invoice.id
      activity_and_hr.each do |i|
        activity = i[:activity]
        hr = i[:hr]
        activity.update_attributes(:invoice_id => invoice_id, :price => hr.value, :currency_id => hr.currency_id)
      end
      
    else
      json[:error] = "Some of the activities don't have hourly rates defined"
      json[:bad_activities] = bad_activities.map {|i| i[:activity].id}
    end
    
    render :json => json
  end
  
  protected

  def set_filter
    @filter = ActivityFilter.new(@params_filter || {:from => nil, :to => nil})
    
    if current_user.admin
      @users = User.employees
      user = (user_id = @filter.user_id).blank? ? nil : User.find(user_id)
      @projects = user ? user.projects : Project.all
      @clients = Client.all
    else
      @filter.user_id = current_user.id
      @projects = current_user.projects
    end
  end
  
  def set_activity
    @activity = current_user.admin ? Activity.find_by_id(params[:id]) : current_user.activities.find_by_id(params[:id])
    @found = !@activity.nil?
  end
end
