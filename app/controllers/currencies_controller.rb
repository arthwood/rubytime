class CurrenciesController < ApplicationController
  before_filter :admin_required
  
  def index
    set_list_data
    set_new
  end
  
  def new
    set_new
    
    render :partial => 'form'
  end

  def create
    @currency = Currency.new(params[:currency])

    if @currency.save
      flash[:info] = 'Currency was successfully created.'
      redirect_to currencies_url
    else
      flash.now[:error] = "Currency couldn't be created"
      
      set_list_data
      
      render :action => :index
    end
  end

  def edit
    @currency = Currency.find(params[:id])
    
    render :partial => 'form'
  end
  
  def update
    @currency = Currency.find(params[:id])

    if @currency.update_attributes(params[:currency])
      flash[:info] = 'Currency was successfully updated.'
      redirect_to currencies_url
    else
      set_list_data
      flash.now[:error] = "Currency couldn't be updated"
      
      render :action => :index
    end
  end
  
  def destroy
    @currency = Currency.find(params[:id])
    @currency.destroy
    
    set_list_data
    
    render :json => {:html => render_to_string(:partial => 'listing'), :success => true} 
  end
  
  private
  
  def set_new
    @currency = Currency.new
  end
  
  def set_list_data
    @currencies = Currency.all
  end
end
