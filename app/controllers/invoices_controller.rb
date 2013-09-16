class InvoicesController < ApplicationController

  # Methods to get the invoice given their status_name
  # status_name defined in Invoice model
  Invoice::STATUS_NAME.each do |status|
    define_method "#{status}" do
      @invoices = current_account.send("#{status}_invoices")
      render "index"
    end
  end


  def index
    @invoices = Invoice.all
  end

end
