class ActivitiesController < ApplicationController
  before_filter :login_required, :only => [:search, :calendar]
  before_filter :editor_required, :except => [:index, :search, :calendar]
  
  def index
    redirect_to login_url and return unless logged_in?
    set_activity_filter(nil)
  end
  
  def export
    @activities = Activity.find(params[:ids], :include => [:project, :user])
    @filename = 'activities_report'
    @hide_users = (params[:hide_users] == '1')
    
    respond_to do |format|
      format.csv {
        send_data Activity.to_csv(@activities), :type => :csv, :filename => "#{@filename}.csv"
      }
      format.pdf {
        send_data Activity.to_pdf(@activities, 'Activities', @hide_users), :type => :pdf, :filename => "#{@filename}.pdf" 
      }
    end
  end
  
  def search
    set_activity_filter(params[:filter])
    
    @activities = Activity.search(@filter)
    
    if current_user.admin?
      filter_client_id = @filter.client_id.to_i
      @client = @clients.detect {|i| i.id == filter_client_id}
      @invoices = @client && @client.invoices || Invoice.all
    end
    
    render :partial => 'results'
  end
  
  def calendar
    user_id = params[:user_id]
    date = params[:date]
    @date = date.present? ? Date.parse(date) : Date.current
    
    if current_user.admin?
      @user = user_id.present? ? User.find_by_id(user_id) : current_user
      @users = User.employees
    elsif current_user.client?
      @users = current_user.client.collaborators
      # TODO: change to "@users.find" when collaborators can be used as collection
      @user = user_id.present? ? @users.detect {|i| i.id == user_id} : @users.first
    else
      @user = current_user
      @users = [@user]
    end
    
    if @user
      @activities = @user.activities.for_day(@date)
      @activities = @activities.for_projects(current_user.client.projects) if current_user.client?
      @days_off = @user.free_days
    else
      @activities = []
      @days_off = []
    end
    
    @days_off_hash = Hash[@days_off.map {|i| [i.date, i] }]
    @first_day = @date.beginning_of_month
    @n = @date.end_of_month.mday
    @fwd = @first_day.wday
    @wd = 1
    @k = 7
    @k0 = (@fwd - @wd + @k) % @k
    @rows = ((@k0 + @n) / @k.to_f).ceil
  end
  
  def missed
    set_missed_activity_filter(nil)
  end
  
  def search_missed
    set_missed_activity_filter(params[:filter])
    @results = Activity.search_missed(@filter)
    
    render :partial => 'activities/missed/results'
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
    
    data[:user_id] = current_user.id unless current_user.admin?
    
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
    
    render :json => {:activity => @activity, :success => @found}
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
    hourly_rates = @client.projects.map(&:hourly_rates).flatten.sort_by(&:date)
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
      date = Date.current
      activity_and_hr.each do |i|
        activity = i[:activity]
        hr = i[:hr]
        activity.update_attributes(:invoice_id => invoice_id, :invoiced_at => date, :value => hr.value, :currency_id => hr.currency_id)
      end
    else
      json[:error] = "Some of the activities don't have hourly rates defined"
      json[:bad_activities] = bad_activities.map {|i| i[:activity].id}
    end
    
    render :json => json
  end
  
  def day_off
    user = current_user.admin? ? User.find(params[:user_id]) : current_user
    @free_day = user.free_days.create(:date => params[:date])
    
    render :json => {:date => @free_day.date}
  end
  
  def revert_day_off
    user = current_user.admin? ? User.find(params[:user_id]) : current_user
    @free_day = user.free_days.find_by_date(params[:date]).destroy
    
    render :json => {:date => @free_day.date}
  end
  
  protected
  
  def set_activity_filter(data)
    @filter = ActivityFilter.new(data)
    
    if current_user.admin?
      @users = User.employees
      user = (user_id = @filter.user_id).present? ? User.find(user_id) : nil
      @projects = user ? user.projects : Project.all
      @clients = Client.all
    elsif current_user.client?
      @filter.client_id = current_user.client_id
      @projects = current_user.client.projects
      @users = current_user.client.collaborators
    else
      @filter.user_id = current_user.id
      @projects = current_user.projects
    end
  end
  
  def set_missed_activity_filter(data)
    @filter = MissedActivityFilter.new(data)
    
    if current_user.admin?
      @users = User.employees
    elsif current_user.client?
      @users = current_user.client.collaborators
    end
  end
  
  def set_activity
    @activity = current_user.admin? ? Activity.find_by_id(params[:id]) : current_user.activities.find_by_id(params[:id])
    @found = @activity.present?
  end
end
