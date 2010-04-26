class HourlyRatesController < ApplicationController
  def new
    @project = Project.find(params[:project_id])
    @hourly_rate = @project.hourly_rates.build(:role_id => params[:role_id])
    
    render :partial => 'form'
  end
  
  def create
    @project = Project.find(params[:project_id])
    @hourly_rate = @project.hourly_rates.create(params[:hourly_rate])
    @role = @hourly_rate.role
    
    if @hourly_rate.valid?
      @hourly_rates = @project.hourly_rates.with_role(@role)
      
      render :json => {:html => render_to_string(:partial => 'list', :object => @hourly_rates), :success => true}
    else
      render :json => {:html => render_to_string(:partial => 'form'), :success => false}
    end
  end
  
  def edit
    @hourly_rate = HourlyRate.find(params[:id])
    
    render :partial => 'form'
  end
  
  def update
    @hourly_rate = HourlyRate.find(params[:id])

    if @hourly_rate.update_attributes(params[:hourly_rate])
      render :json => {:hourly_rate => @hourly_rate.reload, :success => success}
    else
      render :json => {:html => render_to_string(:partial => 'form'), :success => success}
    end
  end
  
  def destroy
    @hourly_rate = HourlyRate.find(params[:id])
    @hourly_rate.destroy
    
    render :json => @hourly_rate.to_json, :success => true
  end
end
