require 'test_helper'

class InvoiceItemTest < ActiveSupport::TestCase

  def setup
    @account = Account.new(:name => "Masev", :subdomain => "masev")
    @plan = Plan.new(:name => "trial")
    @plan.save
    @account.save
    @invoice = @account.invoices.new(number: 20, subject: "Prueba de Factura", 
                                    open_date: "10/02/2014", due_days: 30, currency: "CLP", 
                                    taxed: false, company_id: 10, total: 1000, net_total: 1000
                                    )
    @invoice_item = @invoice.invoice_items.build(type: "producto", quantity: 1, price: 1000)
  end
  
  test "Total should be the product of price and quantity" do
    @invoice_item.save
    assert_equal(@invoice_item.quantity * @invoice_item.price, @invoice_item.total)
  end
  

end
