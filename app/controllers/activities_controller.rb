class ActivitiesController < ApplicationController
  skip_before_filter :login_required, :only => :index
  
  def index
    redirect_to login_url and return unless logged_in?
    
    @filter = params[:filter] || {:date => {:from => nil, :to => nil}}
    
    a = current_user.admin
    b = @filter[:user_id].blank?
    c = (@filter[:user_id] == current_user.id)
    
    @filter[:user_id] = current_user.id if a && b || !a && (b || !c)
    
    @user = User.find(@filter[:user_id])
    @activity = Activity.new
    @activities = Activity.search(@filter)
    @users = User.employees
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
