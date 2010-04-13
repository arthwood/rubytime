class ActivitiesController < ApplicationController
  skip_before_filter :login_required, :only => :index
  
  def index
    redirect_to login_url and return unless logged_in?
    
    @activities = Activity.all
    @activity = Activity.new
  end

  def show
    @activity = Activity.find(params[:id])
  end

  def edit
    @activity = Activity.find(params[:id])
  end

  def create
    data = params[:activity]
    
    data.user_id = current_user.id unless current_user.admin
    
    @activity = Activity.new(data)
    
    if @activity.save
      flash[:notice] = 'Activity was successfully created.'
      
      redirect_to :action => :index
    else
      @activities = Activity.all
      
      flash.now[:error] = "Activity couldn't be created"
      
      render :action => :index
    end
  end

  def update
    @activity = Activity.find(params[:id])

    if @activity.update_attributes(params[:activity])
      flash[:notice] = 'Activity was successfully updated.'
      redirect_to @activity
    else
      render :action => :edit
    end
  end

  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy

    redirect_to activities_url
  end
end
