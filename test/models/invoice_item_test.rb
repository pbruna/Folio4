require 'test_helper'

class InvoiceItemTest < ActiveSupport::TestCase

  def setup
    @plan = Plan.new(:name => "trial")
    @plan.save
    @account = Account.new(:name => "Masev", :subdomain => "maseva")
    @user = @account.users.new(email: "pbruna@gmail.com", password: "172626292")
    @account.save
    @user.save
    @contact = Contact.new(company_id: 10, name: "Patricio", email: "pbruna@itlinux.cl")
    @contact.save
    @invoice = @account.invoices.new(number: 20, subject: "Prueba de Factura", 
                                    active_date: "10/02/2014", due_days: 30, currency: "CLP", 
                                    taxed: false, company_id: 10, total: 1000, net_total: 1000,
                                    contact_id: @contact.id 
                                    )
    @invoice_item = @invoice.invoice_items.build(type: "producto", quantity: 2, price: 1000)
    @reminder = @invoice.build_reminder
  end
  
  test "Total should be the product of price and quantity" do
    @invoice_item.save
    assert_equal(@invoice_item.quantity * @invoice_item.price, @invoice_item.total)
  end
  
  test "round price and total if invoice currency is CLP" do
    @invoice_item.price = 13.4
    @invoice_item.quantity = 2
    @invoice.save
    assert_equal(13, @invoice_item.price.to_i)
    assert_equal(26, @invoice_item.total.to_i)
  end
  
  test "item should have a number, 1 for default" do
    @invoice.save
    assert_equal(1, @invoice.invoice_items.first.number)
  end
  
  test "items should have consecutives numbers" do
    invoice_item_2 = @invoice.invoice_items.build(type: "producto", quantity: 3, price: 1000)
    @invoice.save
    assert_equal(1, @invoice.invoice_items[0].number)
    assert_equal(2, @invoice.invoice_items[1].number)
  end
  
  test "items should still have consecutives numbers if i delete a items" do
    invoice_item_2 = @invoice.invoice_items.build(type: "producto", quantity: 3, price: 1000)
    invoice_item_3 = @invoice.invoice_items.build(type: "producto", quantity: 3, price: 1000)
    @invoice.save
    @invoice.invoice_items[1].destroy
    assert_equal(1, @invoice.invoice_items[0].number)
    assert_equal(2, @invoice.invoice_items[1].number)    
  end

end
