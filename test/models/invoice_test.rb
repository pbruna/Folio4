require 'test_helper'
require 'pp'

class InvoiceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
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
    resource = File.new(Rails.root.to_s + "/test/fixtures/files/test-file.png")
    @attachment = @invoice.attachments.build(category: Attachment.categories[:invoice], resource: resource)
    @reminder = @invoice.build_reminder
  end
  
  # test "suggested number should return the next invoice number" do
  #   assert_equal(21, @invoice.suggested_number)
  # end
  
  test "Calc due date when saved" do
    assert(@invoice.save, "No se guardo")
    assert_equal("2014-03-12", @invoice.due_date.to_s(:db))
  end
  
  test "Dont calc tax_total when is not taxed" do
    @invoice.taxed = false
    @invoice.save
    assert_equal(@invoice.total.to_i, @invoice.net_total.to_i)
  end

  test "Ommit number validation for draft invoice" do 
    @invoice.number = nil
    assert(@invoice.save, "Deberia guardarse")
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
    @invoice.taxed = false
    @invoice.currency_convertion_rate = 500
    assert(@invoice.save, "No se guardó.")
    expected_net_total = @invoice.calculate_net_total_from_currency_total
    assert_equal(expected_net_total.to_i, @invoice.net_total.to_i)
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
  
  test "you can only pay an invoice when is active" do
    @invoice.save
    @invoice.total_payed = @invoice.total
    assert(!@invoice.save, "Should not be saved")
  end
  
  test "only close the invoice when total_payed is equal to total" do@invoice.save
    @invoice.active
    @invoice.total_payed = @invoice.total - 100
    @invoice.save
    assert_equal("active", @invoice.status)
  end
  
  test "when total_payed is equal to total the invoice gets closed" do
    @invoice.save
    @invoice.active
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
  
  test "invoice should have a default reminder" do
    @invoice.save
    reminder = @invoice.reminder
    assert_equal("Date", reminder.notification_date.class.to_s)
    assert_equal("Recordatorio vencimiento Factura 20", reminder.subject)
    assert_equal("2014-03-04", reminder.notification_date.to_s)
  end
  
  test "active reminder when activating invoice" do
    @invoice.save
    @invoice.active
    assert(@invoice.reminder.active?, "Reminder debería estar activo")
  end
  
  test "update reminder date when activating invoice" do
    @invoice.save
    @invoice.active_date = Date.parse("2014-07-01")
    @invoice.save
    @invoice.active
    @invoice.save
    assert_equal("2014-07-22", @invoice.reminder.notification_date.to_s)
  end

  test "invoice should have a contact when active" do
    @invoice.save
    assert_equal("Contact", @invoice.contact.class.to_s)
    @invoice.contact = nil
    @invoice.save
    assert(!@invoice.may_active?, "Failure message.")
  end

  
end
