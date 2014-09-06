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
        @attachment = @invoice.attachments.build(category: Attachment.categories[:invoice], resource: resource, author_id: 10, author_type: "User", account_id: 10)
    @reminder = @invoice.build_reminder
  end
  
  def teardown
    @invoice.delete
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
  
  test "only close the invoice when total_payed is equal to total" do
    @invoice.save
    @invoice.active
    @invoice.total_payed = @invoice.total - 100
    @invoice.save
    assert_not_equal("closed", @invoice.status)
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
    assert_equal("2014-09-23", @invoice.reminder.notification_date.to_s)
  end

  test "invoice should have a contact when active" do
    @invoice.save
    assert_equal("Contact", @invoice.contact.class.to_s)
    @invoice.contact = nil
    @invoice.save
    assert(!@invoice.may_active?, "Failure message.")
  end

  test "destroy only if is draft" do
    @invoice.save
    @invoice.active
    @invoice.save
    assert(!@invoice.destroy, "Solo debe poder eliminar si es Draft")
  end
  
  test "only cancel an invoice if is active" do
    @invoice.save
    assert(!@invoice.may_cancel?, "No debería ser anulada si esta draft")
    @invoice.active
    @invoice.total_payed = @invoice.total
    @invoice.close
    @invoice.save
    assert(!@invoice.may_cancel?, "No debería ser anulada si esta cerrada")
  end

  test "invoice#pay return false unless invoice is active" do
    assert(!@invoice.pay(38373), "Pay funciona sólo si la factura está activa")
  end

  test "invoice#pay should convert string to int" do
    @invoice.save
    @invoice.active
    @invoice.save
    @invoice.pay("$ 323.343")
    assert_equal(323343, @invoice.total_payed.to_i)
  end
  
  test "sum the total_payed when doing payments" do
    @invoice.save
    @invoice.active
    @invoice.save
    @invoice.pay(@invoice.total.to_i - 200)
    @invoice.pay(200)
    assert(@invoice.closed?, "No se están sumando los abonos")
  end
  
  
  test "close invoice when amount payed is equal than total" do
    @invoice.save
    @invoice.active
    @invoice.save
    @invoice.pay("$ #{@invoice.total.to_i}")
    assert(@invoice.closed?, "Factura debería estar cerrada")
  end
  
  test "if today is greater tha due date, the invoice is due" do
    @invoice.save
    @invoice.active
    @invoice.save
    @invoice.due_date = Date.today.months_ago 2
    @invoice.save
    assert_equal("due", @invoice.status)
  end
  
  test "save original original_currency_total with 2 decimals when currency is UF" do
    @invoice_item.price = 12.2
    @invoice_item_2 = @invoice.invoice_items.build(type: "producto", quantity: 1, price: 12.1)
    @invoice.currency = "UF"
    @invoice.save
    assert_equal(36.5, @invoice.original_currency_total.to_f)
  end
  
  test "save original original_currency_total with 2 decimals when currency is USD" do
    @invoice_item.price = 101.2
    @invoice_item_2 = @invoice.invoice_items.build(type: "producto", quantity: 1, price: 103.2)
    @invoice.currency = "USD"
    @invoice.save
    assert_equal(305.6, @invoice.original_currency_total.to_f)
  end
  
  test "save round down original_currency_total when currency is CLP" do
    @invoice_item.price = 12.2
    @invoice_item_2 = @invoice.invoice_items.build(type: "producto", quantity: 1, price: 12.2)
    @invoice.save
    assert_equal(36, @invoice.original_currency_total.to_i)
  end
  
  test "save round up original_currency_total when currency is CLP" do
    @invoice_item.price = 12.6
    @invoice_item_2 = @invoice.invoice_items.build(type: "producto", quantity: 1, price: 12.4)
    @invoice.save
    assert_equal(38, @invoice.original_currency_total.to_i)
  end
  
  test "Update due date when activating it" do
    @invoice.save
    @invoice.due_date = "12/03/2014"
    @invoice.save
    @invoice.active
    assert_equal(Date.today + @invoice.due_days, @invoice.due_date)
  end
  
end
