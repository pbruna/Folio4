require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @account = Account.new(:name => "Masev", :subdomain => "masev")
    @plan = Plan.new(:name => "trial")
    @plan.save
    @account.save
    @invoice = @account.invoices.new(number: 20, subject: "Prueba de Factura", 
                                    open_date: "10/02/2014", due_days: 30, currency: "CLP", 
                                    taxed: false, company_id: 10, total: 1000, net_total: 1000
                                    )
    @invoice_item = @invoice.invoice_items.build(type: "producto", quantity: 2, price: 1000)
  end
  
  test "suggested number should return the next invoice number" do
    last_invoice = @account.invoices.last
    invoice = @account.invoices.new
    assert_equal(1, invoice.suggested_number)
  end
  
  test "Calc due date when saved" do
    assert(@invoice.save, "No se guardo")
    assert_equal("2014-03-12", @invoice.due_date.to_s(:db))
  end
  
  test "Dont calc tax_total when is not taxed" do
    @invoice.taxed = false
    @invoice.save
    assert_equal(@invoice.total.to_i, @invoice.net_total.to_i)
  end
  
  test "Calc tax_total when is taxed" do
    @invoice.taxed = true
    @invoice.total = 0
    tax_total = (@invoice_item.price * @invoice_item.quantity * 1.19) - (@invoice_item.price * @invoice_item.quantity)
    assert(@invoice.save, "No se guardo")
    assert_equal(tax_total + @invoice.net_total, @invoice.total.to_i)
    assert_equal(tax_total, @invoice.tax_total.to_i)
  end
  
  test "Calc CLP total if is another currency" do
    @invoice.currency = "USD"
    @invoice.taxed = true
    @invoice.currency_convertion_rate = 500
    @invoice.save
    expected_net_total = (@invoice_item.price * @invoice_item.quantity) * 500
    assert_equal(expected_net_total, @invoice.net_total.to_i)
  end
  
  test "close_date nil if total_payed is < total" do
    @invoice.total_payed = 0
    @invoice.save
    assert_nil(@invoice.close_date)
  end
  
  test "total_payed should not be larger than total" do
    @invoice.save
    @invoice.total_payed = @invoice.total + 2000
    assert(!@invoice.save, "Should not be saved")
  end
  
  test "you can only pay an invoice when is open" do
    @invoice.save
    @invoice.total_payed = @invoice.total
    assert(!@invoice.save, "Should not be saved")
  end
  
  test "only close the invoice when total_payed is equal to total" do@invoice.save
    @invoice.open!
    @invoice.total_payed = @invoice.total - 100
    @invoice.save
    assert_equal("open", @invoice.status)
  end
  
  test "when total_payed is equal to total the invoice gets closed" do
    @invoice.save
    @invoice.open!
    @invoice.total_payed = @invoice.total
    @invoice.save
    assert_equal("closed", @invoice.status)
    assert_equal(Date.today.to_s(:db), @invoice.close_date.to_s(:db))
  end

  test "must have a least one items" do
    @invoice.invoice_items = []
    assert(!@invoice.save, "No se debe guardar sin items.")
  end
  
  test "invoice total should be the sum of the totals of the invoice_items" do
    @invoice_item_2 = @invoice.invoice_items.build(type: "producto", quantity: 2, price: 2000)
    expected_net_total = (@invoice_item.price * @invoice_item.quantity) + (@invoice_item_2.price * @invoice_item_2.quantity)
    @invoice.save
    assert_equal(expected_net_total.to_i, @invoice.net_total.to_i)
    
  end
  
end
