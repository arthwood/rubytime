class HourlyRatesController < ApplicationController
  before_filter :admin_required
  
  def new
    @project = Project.find(params[:project_id])
    @hourly_rate = @project.hourly_rates.build(:role_id => params[:role_id])
    
    render :partial => 'form'
  end
  
  def create
    @project = Project.find(params[:project_id])
    @hourly_rate = @project.hourly_rates.create(params[:hourly_rate])
    @role = @hourly_rate.role
    
    success = @hourly_rate.valid?
    json = {:success => success}
    
    if success
      @hourly_rates = @project.hourly_rates.with_role(@role)
      
      render :json => json.merge(:html => render_to_string(:partial => 'list', :object => @hourly_rates))
    else
      render :json => json.merge(:html => render_to_string(:partial => 'form'))
    end
  end
  
  def edit
    @hourly_rate = HourlyRate.find(params[:id])
    
    render :partial => 'form'
  end
  
  def update
    @hourly_rate = HourlyRate.find(params[:id])
    success = @hourly_rate.update_attributes(params[:hourly_rate])
    json = {:success => success}
    
    if success
      render :json => json.merge(:hourly_rate => @hourly_rate.reload)
    else
      render :json => json.merge(:html => render_to_string(:partial => 'form'))
    end
  end
  
  def destroy
    @hourly_rate = HourlyRate.find(params[:id])
    @hourly_rate.destroy
    
    render :json => {:success => true, :hourly_rate => @hourly_rate}
  end
end
