require 'test_helper'

class CompanyTest < ActiveSupport::TestCase

  def setup
    @plan = Plan.new(:name => "trial")
    @plan.save
    @account = Account.new(:name => "Masev", :subdomain => "maseva")
    @user = @account.users.new(email: "pbruna@gmail.com", password: "172626292")
    @account.save
    @user.save
    @contact = Contact.new(company_id: 10, name: "Patricio", email: "pbruna@itlinux.cl")
    @contact.save
    @company = Company.new(:name => "Acme", :address => "Test", :province => "Test", :city => "Test", :rut => "13.834.853-9", :account_id => @account.id)
  end


  def teardown
    @company.destroy
  end

  test "should have a valid rut" do
    assert_no_difference('Company.count') do
      @company.rut = "13.834.853-8"
      @company.save
    end
    @company.rut = "13.834.853-9"
    assert(@company.save, "No se guardo")
  end
  
  test "cannot delete if have any invoices" do
    @company.save
    @invoice = @account.invoices.new(number: 20, subject: "Prueba de Factura", 
                                    active_date: "10/02/2014", due_days: 30, currency: "CLP", 
                                    taxed: false, company_id: @company.id, total: 1000, net_total: 1000,
                                    contact_id: @contact.id 
                                    )
    @invoice_item = @invoice.invoice_items.build(type: "producto", quantity: 2, price: 1000)
    resource = File.new(Rails.root.to_s + "/test/fixtures/files/test-file.png")
    @attachment = @invoice.attachments.build(category: Attachment.categories[:invoice], resource: resource)
    @reminder = @invoice.build_reminder
    @invoice.save
    assert(!@company.destroy, "No se debería borrar")
  end

end
