class InvoicesController < ApplicationController
  before_filter :admin_required
  
  def index
    set_list
    set_new
  end
  
  def new
    set_new
    
    render :partial => 'form'
  end
  
  def show
    @invoice = Invoice.find(params[:id])
    @filename = "invoice_#{@invoice.client.name}_#{Rubytime::Util.format_date(Date.current)}"
    
    respond_to do |format|
     format.csv {
       send_data @invoice.to_csv, :type => :csv, :filename => "#{@filename}.csv"
     }
     format.pdf {
       send_data @invoice.to_pdf, :type => :pdf, :filename => "#{@filename}.pdf" 
     }
    end
  end
  
  def create
    @invoice = Invoice.new(params[:invoice].merge(:user_id => current_user.id))
    
    if @invoice.save
      flash[:info] = 'Invoice was successfully created.'
      redirect_to invoices_url
    else
      flash.now[:error] = "Invoice couldn't be created"
      
      set_list
      
      render :action => :index
    end
  end
  
  def edit
    @invoice = Invoice.find(params[:id])
    
    render :partial => 'form'
  end
  
  def update
    @invoice = Invoice.find(params[:id])

    if @invoice.update_attributes(params[:invoice])
      flash[:info] = 'Invoice was successfully updated.'
      redirect_to invoices_url
    else
      flash.now[:error] = "Invoice couldn't be updated"
      
      set_list
      
      render :action => :index
    end
  end
  
  def destroy
    @invoice = Invoice.find(params[:id])
    @invoice.destroy
    
    set_list
    
    render :json => {:html => render_to_string(:partial => 'listing'), :success => true} 
  end
  
  private
  
  def set_new
    @invoice = Invoice.new
  end
  
  def set_list
    @invoices = Invoice.all
  end
end
