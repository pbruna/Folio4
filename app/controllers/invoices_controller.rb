class InvoicesController < ApplicationController
  autocomplete :company, :name, :full => true, :scopes => [:for_account]

  # Methods to get the invoice given their status_name
  # status_name defined in Invoice model
  Invoice::STATUS_NAME.each do |status|
    define_method "#{status}" do
      @invoices = current_account.send("#{status}_invoices")
      render "index"
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
  
  def edit
    @invoice = current_account.invoices.find(params[:id])
  end

  def index
    @invoices = current_account.invoices.all
  end
  
  def new
    @invoice = current_account.invoices.new
    @invoice.invoice_items.build
  end
  
  def show
    @invoice = current_account.invoices.find(params[:id])
  end
  
  private
    def invoice_params
      params.require(:invoice).permit(:company_id, :subject,:number, :open_date, 
      :due_days, :currency, :taxed,invoice_items_attributes: [:type, :description, :quantity, :price, :total])
    end
    
    def prices_to_numbers
      params["invoice"]["invoice_items_attributes"].each do |key,value|
        price = params["invoice"]["invoice_items_attributes"][key]["price"].to_s.gsub(/\$\s+/,"").gsub(/\./,"").to_i
        params["invoice"]["invoice_items_attributes"][key]["price"] = price
      end
      params
    end
  

end
