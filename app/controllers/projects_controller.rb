class ProjectsController < ApplicationController
  before_filter :admin_required, :except => :index
  
  def index
    respond_to do |format|
      format.html do
        set_list
        set_new
      end
      
      format.json do
        user_id = params[:user_id]
        @projects = user_id.blank? ? Project.all : User.find(user_id).projects
        
        render :json => @projects
      end
    end
  end
  
  def new
    set_new
    
    render :partial => 'form'
  end
  
  def create
    @project = Project.new(params[:project])
    
    if @project.save
      flash[:info] = 'Project was successfully created.'
      redirect_to projects_url
    else
      flash.now[:error] = "Project couldn't be created"
      
      set_list
      
      render :action => :index
    end
  end

  def edit
    @project = Project.find(params[:id])
    @hourly_rates = @project.hourly_rates
    
    render :partial => 'form'
  end
  
  def update
    @project = Project.find(params[:id])

    if @project.update_attributes(params[:project])
      flash[:info] = 'Project was successfully updated.'
      redirect_to projects_url
    else
      set_list
      flash.now[:error] = "Project couldn't be updated"
      
      render :action => :index
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    set_list
    
    render :json => {:html => render_to_string(:partial => 'listing'), :success => true} 
  end
  
  private
  
  def set_new
    @project = Project.new
  end
  
  def set_list
    @projects = Project.all
  end
end
