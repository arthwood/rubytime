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
    
    @current = (current = params[:current]).blank? ? Date.current : Date.parse(current)
    @first_day = @current.at_beginning_of_month
    @rows = (@first_day.wday + @current.end_of_month.mday - 1) / 7
  end
  
  def show
    @activity = Activity.find(params[:id])
  end
  
  def edit
    @activity = Activity.find(params[:id])
    
    render :partial => 'form'
  end
  
  def create
    data = params[:activity]
    
    data.user_id = current_user.id unless current_user.admin
    
    @activity = Activity.new(data)
    
    if @activity.save
      render :nothing => true
    else
      render :partial => 'form'
    end
  end
  
  def update
    @activity = Activity.find(params[:id])

    if @activity.update_attributes(params[:activity])
      render :nothing => true
    else
      render :partial => 'form'
    end
  end

  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy

    redirect_to activities_url
  end
end
