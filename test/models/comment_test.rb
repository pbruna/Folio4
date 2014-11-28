require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  
  def setup
    @plan = Plan.new(:name => "trial")
    @plan.save
    @account = Account.new(
                            :name => "Masev", :subdomain => "maseva", :rut => "76.530.890-9", 
                            address: "Eliodro Yañez 810", city: "Santiago",
                            e_invoice_enabled: true, e_invoice_resolution_date: "2014/01/01",
                            industry_code: 10398, industry: "Servicios Informaticos"
                            )
    @user = @account.users.new(email: "pbruna@gmail.com", password: "172626292")
    @account.save
    @user.save
    @company = Company.new(name: "Acme", rut: "13.834.853-9", address: "Eliodro Yañez 810", province: "Providencia", city: "Santiago", account_id: @account.id )
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
  end
  
  def teardown
    ActionMailer::Base.deliveries = []
    @dte.destroy if @dte
    @invoice.destroy
    @account.destroy
  end
  
  test "should not send email to company if private" do
    message = "Este es el mensaje"
    comment = @invoice.comments.new_from_system({message: message, 
              account_users_ids: @invoice.account_users_ids, company_users_ids: @invoice.company_users_ids,
              private: true})
    comment.save
    assert(!comment.subscribers_emails.include?(@contact.email), "No deberia enviarse correo al cleinte")
  end
  
  test "Comment from system with email" do
    message = "Este es el mensaje"
    comment = @invoice.comments.new_from_system({message: message, account_users_ids: @invoice.account_users_ids, private: true})
    assert(comment.save, "Failure message.")
    assert_equal(message, comment.message)
    mail = ActionMailer::Base.deliveries.last
    assert_not_nil(mail)
    assert_equal(@user.email, mail['to'].to_s)
  end
  
end
