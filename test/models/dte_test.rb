require 'test_helper'
require 'pp'

class DteTest < ActiveSupport::TestCase
  
  def setup
    stub_request(:any, /#{Rails.configuration.gdexpress[:dte_box]}/).to_rack(FakeGdExpress)
    fake_data
  end
  
  def teardown
    ActionMailer::Base.deliveries = []
    @invoice.dtes.each {|d| d.delete }
    @invoice.delete
    @account.delete
  end
  
  test "dte_from_invoice untaxed should copy correctly" do
    @invoice.active
    @invoice.save
    @dte = @invoice.dtes.first
    assert_equal(34, @dte.tipo_dte)
    assert_equal(@invoice.number, @dte.folio)
    assert_equal(@invoice.active_date, @dte.fch_emis)
    assert_equal(1, @dte.fma_pago)
    assert_equal(@invoice.due_date, @dte.fch_venc)
    assert_equal(@invoice.account.rut.gsub(/\./,"").gsub(/k$/, "K"), @dte.rut_emisor)
    assert_equal(@invoice.account.name, @dte.rzn_soc)
    assert_equal(@invoice.account.industry, @dte.giro_emis)
    assert_equal(@invoice.account.industry_code, @dte.acteco)
    assert_equal(@invoice.account.address, @dte.dir_origen)
    assert_equal(@invoice.account.city, @dte.cmna_origen)
    assert_equal(@invoice.company.rut.gsub(/\./,"").gsub(/k$/, "K"), @dte.rut_recep)
    assert_equal(@invoice.company.name, @dte.rzn_soc_recep)
    assert_equal(@invoice.company.address, @dte.dir_recep, "Direccion")
    assert_equal(@invoice.company.province, @dte.cmna_recep, "Comuna")
    assert_equal(@invoice.company.industry, @dte.giro_recep, "Giro")
    assert_equal(nil, @dte.mnt_neto, "Neto")
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
    @invoice.active
    @invoice.save
    @dte = @invoice.dtes.first
    assert_not_nil(@dte.cond_pago, "Condicion de Pago")
    assert_equal(@contact.name, @dte.contacto)
    assert_equal("#{@invoice.due_days} días", @dte.cond_pago)
    assert_equal(33, @dte.tipo_dte)
    assert_equal(@invoice.net_total, @dte.mnt_neto, "Neto")
    assert_equal(0, @dte.mnt_exe, "Exento")
    assert_equal(@invoice.tax_rate, @dte.tasa_iva, "Tasa IVA")
    assert_equal(@invoice.tax_total, @dte.iva, "Total Iva")
    assert_equal(@invoice.total, @dte.mnt_total, "Total")
  end
  
  test "only save a dte if it exists or is created from an active invoice" do
    assert_raise(Dte::InvalidDTE) { 
      Dte.prepare_from_invoice(@invoice)
    }
  end
  
  # test "Dont create same type DTE" do
  #   @invoice.number = 8383
  #   @invoice.active
  #   # assert(@invoice.save, "No se guardo")
  #   assert(@invoice.valid?, "Failure message.")
  #   assert(@invoice.has_dte?, "No tiene DTE")
  #   assert_raise(Dte::InvalidDTE) {
  #     @dte = Dte.prepare_from_invoice(@invoice)
  #   }
  # end
  
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
  
  # test "generate correct fields for dte 61 when invoice cancel" do
  #   @invoice.active
  #   @invoice.save
  #   @invoice.cancel
  #   @invoice.save
  #   assert(@invoice.reload.dtes.size > 1, "No se creo la NC")
  #   dte_nc = @invoice.dtes.last
  #   dte_invoice =  @invoice.dte_invoice
  #   attrs_intersection = dte_invoice.attributes & dte_nc.attributes
  #   assert_equal(Invoice::DTE_TYPES[:credit_note], dte_nc.tipo_dte)
  #   diferente_fields = ["cod_ref", "created_at", "fch_ref", "folio", "folio_ref", "id", "razon_ref", "tipo_dte", "tpo_doc_ref", "updated_at"]
  #   assert_equal(1, dte_nc.cod_ref)
  #   assert_equal(attrs_intersection.keys.sort, diferente_fields)
  # end
  
  test "account.suggest_nc_folio should return a valid nc number to use" do
    @account.dte_invoice_start_number = 20
    @account.dte_nc_start_number = 20
    @account.save
    assert_equal(@account.dte_nc_start_number, Dte.suggest_nc_folio(@account.id))
  end

  test "Upcase k if rut ends in lowercase k" do
    @invoice.active
    @invoice.save
    dte = @invoice.dte_invoice
    assert_equal(dte.rut_emisor, "76530890-K")
  end
  
  
  
  
  
  
  
end
