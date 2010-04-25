class ActivitiesController < ApplicationController
  skip_before_filter :login_required, :only => :index
  
  def index
    redirect_to login_url and return unless logged_in?
    
    @params_filter = params[:activity_filter]
    @filter = ActivityFilter.new(@params_filter || {:from => nil, :to => nil})
    
    @users = User.employees
    
    if current_user.admin
      user = (user_id = @filter.user_id).blank? ? nil : User.find(user_id)
      @projects = user ? user.projects : Project.all
    else
      @filter.user_id = current_user.id
      @projects = current_user.projects
    end
    
    @activities = Activity.search(@filter)
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
    
    if @activity.save
      render :json => {:activity => @activity, :success => true}
    else
      render :json => {:html => render_to_string(:partial => 'form'), :success => false}
    end
  end
  
  def update
    set_activity
    success = @found && @activity.update_attributes(params[:activity])
    
    if success 
      render :json => {:activity => @activity.reload, :success => success}
    else
      render :json => {:html => render_to_string(:partial => 'form'), :success => success}
    end
  end

  def destroy
    set_activity
    
    @activity.destroy if @found
    
    render :json => @activity.to_json, :success => @found
  end
  
  protected
  
  def set_activity
    @activity = current_user.admin ? Activity.find_by_id(params[:id]) : current_user.activities.find_by_id(params[:id])
    @found = !@activity.nil?
  end
end
