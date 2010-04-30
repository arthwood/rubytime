class CurrenciesController < ApplicationController
  before_filter :admin_required
  
  def index
    @currencies = Currency.all
    @currency = Currency.new
  end
  
  def new
    @currency = Currency.new
    
    render :partial => 'form'
  end

  def create
    @currency = Currency.new(params[:currency])

    if @currency.save
      flash[:info] = 'Currency was successfully created.'
      redirect_to currencies_url
    else
      flash.now[:error] = "Currency couldn't be created"
      
      @currencies = Currency.all
      
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
      @currencies = Currency.all
      flash.now[:error] = "Currency couldn't be updated"
      
      render :action => :index
    end
  end

  def destroy
    @currency = Currency.find(params[:id])
    @currency.destroy
    @currencies = Currency.all
    
    render :json => {:html => render_to_string(:partial => 'listing'), :success => true} 
  end
end
