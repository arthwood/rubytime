class RolesController < ApplicationController
  def index
    @roles = Role.all
    @role = Role.new
  end

  def create
    @role = Role.new(params[:role])

    if @role.save
      flash[:info] = 'Role was successfully created.'
      redirect_to roles_url
    else
      flash.now[:error] = "Role couldn't be created"
      
      @roles = Role.all
      
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
      @roles = Role.all
      flash.now[:error] = "Role couldn't be updated"
      
      render :action => :index
    end
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    @roles = Role.all
    
    render :partial => 'listing'
  end
end
