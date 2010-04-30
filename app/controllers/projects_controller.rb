class ProjectsController < ApplicationController
  before_filter :admin_required
  
  def index
    respond_to do |format|
      format.html do
        @projects = Project.all
        @project = Project.new
      end
      
      format.json do
        user_id = params[:user_id]
        @projects = user_id.blank? ? Project.all : User.find(user_id).projects
        
        render :json => @projects.to_json
      end
    end
  end
  
  def new
    @project = Project.new
    
    render :partial => 'form'
  end
  
  def create
    @project = Project.new(params[:project])
    
    if @project.save
      flash[:info] = 'Project was successfully created.'
      redirect_to projects_url
    else
      flash.now[:error] = "Project couldn't be created"
      
      @projects = Project.all
      
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
      @projects = Project.all
      flash.now[:error] = "Project couldn't be updated"
      
      render :action => :index
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    @projects = Project.all
    
    render :json => {:html => render_to_string(:partial => 'listing'), :success => true} 
  end
end
