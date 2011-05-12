class RolesController < ApplicationController
  before_filter :admin_required
  
  def index
    set_list
    set_new
  end

  def new
    set_new
    
    render :partial => 'form'
  end
  
  def create
    @role = Role.new(params[:role])

    if @role.save
      flash[:info] = 'Role was successfully created.'
      redirect_to roles_url
    else
      flash.now[:error] = "Role couldn't be created"
      
      set_list
      
      render :action => :index
    end
  end

  def edit
    @role = Role.find(params[:id])
    
    render :partial => 'form'
  end
  
  def update
    @role = Role.find(params[:id])

    if @role.update_attributes(params[:role])
      flash[:info] = 'Role was successfully updated.'
      redirect_to roles_url
    else
      flash.now[:error] = "Role couldn't be updated"
      
      set_list
      
      render :action => :index
    end
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    
    set_list
    
    render :json => {:html => render_to_string(:partial => 'listing'), :success => true} 
  end
  
  private
  
  def set_new
    @role = Role.new
  end
  
  def set_list
    @roles = Role.all
  end
end
