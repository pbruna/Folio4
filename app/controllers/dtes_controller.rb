class DtesController < ApplicationController
  
  def show
    respond_to do |format|
      format.html
      format.json { render json: {message: "Funciono"}}
    end
    
  end
  
  def status
    invoice = Invoice.find params[:invoice_id]
    dte = invoice.dtes.processing
    respond_to do |format|
      format.html
      format.json { render json: dte}
    end
  end
  
  
  def index
    
  end
  
end
