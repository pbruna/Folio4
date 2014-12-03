require 'test_helper'

class DtesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @request.host = "masev.test.host"
    @account = Account.new(
                            :name => "Masev", :subdomain => "masev", :rut => "76.530.890-9", 
                            address: "Eliodro Yañez 810", city: "Santiago",
                            e_invoice_enabled: true, e_invoice_resolution_date: "2014/01/01",
                            industry_code: 10398, industry: "Servicios Informaticos"
                            )
    @plan = Plan.new(:name => "trial")
    @plan.save
    @current_user = @account.users.build
    @current_user.email = "test@test.com"
    @current_user.password = "kdldlkdkdkd"
    @account.save
    @company = Company.new(name: "Acme", rut: "13.834.853-9", address: "Eliodro Yañez 810", province: "Providencia", city: "Santiago", account_id: @account.id, industry: "Servicios Informaticos" )
    @company.save
    @contact = Contact.new(company_id: @company.id, name: "Patricio", email: "pbruna@itlinux.cl")
    @contact.save
    @invoice = @account.invoices.new(number: 20, subject: "Prueba de Factura", 
                                    active_date: "10/02/2014", due_days: 30, currency: "CLP", 
                                    taxed: false, company_id: @company.id, total: 1000, net_total: 1000,
                                    contact_id: @contact.id 
                                    )
    @invoice_item = @invoice.invoice_items.build(type: "producto", quantity: 2, price: 1000)
    resource = File.new(Rails.root.to_s + "/test/fixtures/files/test-file.png")
        @attachment = @invoice.attachments.build(category: Attachment.categories[:invoice], resource: resource, author_id: 10, author_type: "User", account_id: 10)
    @reminder = @invoice.build_reminder
    @invoice.save
    @invoice.active
    @invoice.save
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in @current_user
  end
  
  def teardown
    @account.destroy
    @plan.destroy
    sign_out @current_user
  end
  
  def json
      ActiveSupport::JSON.decode @response.body
  end
  
  test "status return type should be json" do
    get :status, {invoice_id: @invoice.id, format: "json"}
    assert_equal(@invoice.id, json[0]["invoice_id"].to_i)
  end
  
  test "should return invoice_id and emmited true or false" do
    get :status, {invoice_id: @invoice.id, format: "json"}
    assert_not_nil(json[0]["invoice_id"])
    assert_not_nil(json[0]["processed"])
  end
  
  
  
end
