require 'test_helper'
require 'pp'

class DteTest < ActiveSupport::TestCase
  
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
    @invoice.dtes.each {|d| d.destroy }
    @invoice.destroy
    @account.destroy
  end
  
  test "dte_from_invoice untaxed should copy correctly" do
    @dte = Dte.new Dte.prepare_from_invoice(@invoice)
    assert_equal(34, @dte.tipo_dte)
    assert_equal(@invoice.number, @dte.folio)
    assert_equal(@invoice.active_date, @dte.fch_emis)
    assert_equal(1, @dte.fma_pago)
    assert_equal(@invoice.due_date, @dte.fch_venc)
    assert_equal(@invoice.account.rut, @dte.rut_emisor)
    assert_equal(@invoice.account.name, @dte.rzn_soc)
    assert_equal(@invoice.account.industry, @dte.giro_emis)
    assert_equal(@invoice.account.industry_code, @dte.acteco)
    assert_equal(@invoice.account.address, @dte.dir_origen)
    assert_equal(@invoice.account.city, @dte.cmna_origen)
    assert_equal(@invoice.company.rut, @dte.rut_recep)
    assert_equal(@invoice.company.name, @dte.rzn_soc_recep)
    assert_equal(@invoice.net_total, @dte.mnt_neto, "Neto")
    assert_equal(@invoice.net_total, @dte.mnt_exe, "Exento")
    assert_equal(@invoice.tax_rate, @dte.tasa_iva, "Tasa IVA")
    assert_equal(@invoice.tax_total, @dte.iva, "Total Iva")
    assert_equal(@invoice.total, @dte.mnt_total, "Total")
    assert_equal(@invoice.account_id, @dte.account_id)
    assert_equal(@invoice.company_id, @dte.company_id)
    assert_equal(@invoice.id, @dte.invoice_id)
  end
  
  test "dte_from_invoice taxed should copy the data correctly" do
    @invoice.taxed = true
    @invoice.save
    @dte = Dte.new Dte.prepare_from_invoice(@invoice)
    assert_equal(33, @dte.tipo_dte)
    assert_equal(@invoice.net_total, @dte.mnt_neto, "Neto")
    assert_equal(@invoice.net_total, @dte.mnt_exe, "Exento")
    assert_equal(@invoice.tax_rate, @dte.tasa_iva, "Tasa IVA")
    assert_equal(@invoice.tax_total, @dte.iva, "Total Iva")
    assert_equal(@invoice.total, @dte.mnt_total, "Total")
  end
  
  test "only save a dte if it exists or is created from an active invoice" do
    @dte = Dte.new Dte.prepare_from_invoice(@invoice)
    assert(!@dte.save, "No se debería guardar porque la factura esta en borrador.")
  end
  
  test "Dont create same type DTE" do
    @invoice.active
    assert(@invoice.save, "No se guardo")
    assert(@invoice.valid?, "Failure message.")
    assert(@invoice.has_dte?, "No tiene DTE")
    @dte = Dte.new Dte.prepare_from_invoice(@invoice)
    @dte.save
    assert(!@dte.save, "No Se debería guardar DTE del mismo tipo porque la factura ya creo uno al activarlo.")
  end
  
  test "after create we should chceck if it wast processed" do
    @invoice.active
    @invoice.save
    @dte = @invoice.dtes.last
    assert_not_nil(@dte.processed?)
  end
  
  test "After a dte is processed we add a comment on the invoice and send the email" do
    @invoice.active
    @invoice.save
    comments = @invoice.comments.size
    @dte = @invoice.dtes.last
    @dte.processed = true
    @dte.error_log = "El dte ha fallado"
    assert @dte.save
    mail = ActionMailer::Base.deliveries.last
    assert_not_nil(mail)
    assert_equal(@user.email, mail['to'].to_s)
  end
  
  test "generate correct fields for dte 61 when invoice cancel" do
    @invoice.active
    @invoice.save
    @invoice.cancel
    @invoice.save
    assert(@invoice.reload.dtes.size > 1, "No se creo la NC")
    dte_nc = @invoice.dtes.last
    dte_invoice =  @invoice.dte_invoice
    attrs_intersection = dte_invoice.attributes & dte_nc.attributes
    assert_equal(Invoice::DTE_TYPES[:credit_note], dte_nc.tipo_dte)
    diferente_fields = ["cod_ref", "created_at", "fch_emis", "folio", "id", "razon_ref", "tipo_dte", "updated_at"]
    assert_equal(1, dte_nc.cod_ref)
    assert_equal(attrs_intersection.keys.sort, diferente_fields)
  end

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
end
