class InvoicesController < ApplicationController
  autocomplete :company, :name, :full => true, :scopes => [:for_account]
  skip_before_filter :verify_authenticity_token, :only => :change_status

  # Methods to get the invoice given their status_name
  # status_name defined in Invoice model
  Invoice::STATUS_NAME.each do |status|
    define_method "#{status}" do
      @invoices = current_account.send("#{status}_invoices")
      render "index"
    end
  end


  def activate_from_modal
    @invoice = current_account.invoices.find(params[:id])
    @invoice.attachments.build
    respond_to do |format|
      format.html {render layout: false}
      format.js {render :template => "invoice_activation_modal", layout: false}
    end
  end
  
  def change_status
    @invoice = current_account.invoices.find(params[:id])
    
    respond_to do |format|
      if @invoice.change_status(invoice_params)
        flash.now[:notice] = "Venta activada correctamente"
        format.html {redirect_to @invoice}
        format.js { render 'show'}
      else
        flash[:error] = "No pudo cambiarse el estado de la venta"
        format.html { redirect_to @invoice }
        format.js { render 'change_status_error'}
      end
    end
  end

  def create
    params = prices_to_numbers
    @invoice = current_account.invoices.new(invoice_params)
    if @invoice.save
      flash.now[:notice] = "Venta guardada correctamente."
      redirect_to invoice_path(@invoice)
    else
      flash.now[:error] = "No pudimos guardar esta venta, por favor corrige los errores indicados."
      render 'new'
    end
  end
  
  def update
    params = prices_to_numbers
    @invoice = current_account.invoices.find(params[:id])
    if @invoice.update_invoice(invoice_params)
      flash.now[:notice] = "Venta actualizada correctamente"
      redirect_to invoice_path(@invoice)
    else
      flash.now[:error] = "No pudimos guardar esta venta, por favor corrige los errores indicados."
      render 'edit'
    end
  end  
  
  def edit
    @invoice = current_account.invoices.find(params[:id])
  end

  def index
    @invoices = current_account.invoices.all
  end
  
  def new
    @invoice = current_account.invoices.new
    @invoice.invoice_items.build
    @invoice.attachments.build
    @invoice.build_reminder
  end
  
  def show
    @invoice = current_account.invoices.find(params[:id])
  end
  
  private
    def invoice_params
      params.require(:invoice).permit(:id, :company_id, :new_state, :subject,:number, :active_date, 
      :due_days, :currency, :contact_id, :taxed,invoice_items_attributes: [:id, :type, :description, :quantity, :price, :total, :_destroy],
        reminder_attributes: [:notification_date, :subject, :message],
        attachments_attributes: [:name, :category, :resource])
    end
    
    def prices_to_numbers
      return params if params["invoice"]["invoice_items_attributes"].nil?
      params["invoice"]["invoice_items_attributes"].each do |key,value|
        price = params["invoice"]["invoice_items_attributes"][key]["price"].to_s.gsub(/\$\s+/,"").gsub(/\./,"").to_i
        params["invoice"]["invoice_items_attributes"][key]["price"] = price
      end
      params
    end
  

end
