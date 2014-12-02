class Dte < ActiveRecord::Base

  DTE_OK_MESSAGE = "El DTE se proceso correctamente y pueden verlo en la opción DTEs de la Venta"
  DTE_FAILED_MESSAGE = "Ocurrió un problema al procesar el DTE, más información disponible en la pestaña DTEs"
  DTE_CHECK_INTERVAL_SECONDS = 1
  DTE_TYPES = {33 => "factura afecta", 34 => "factura exenta", 61 => "nota de credito", "61b" => "n.c. ajuste precio"}
  INVOICE_DTE_MAPPINGS = {
    "number" => "folio",
    "active_date" => "fch_emis",
    "due_date" => "fch_venc",
    "account_rut" => "rut_emisor",
    "account_name" => "rzn_soc",
    "account_industry" => "giro_emis",
    "account_industry_code" => "acteco",
    "account_address" => "dir_origen",
    "account_city" => "cmna_origen",
    "company_rut" => "rut_recep",
    "company_name" => "rzn_soc_recep",
    "net_total" => "mnt_exe",
    "tax_rate" => "tasa_iva",
    "tax_total" => "iva",
    "total" => "mnt_total",
    "account_id" => "account_id",
    "company_id" => "company_id",
    "id" => "invoice_id",
  }
  
  belongs_to :invoice
  belongs_to :account
  belongs_to :company
  
  validates_uniqueness_of :folio, scope: [:invoice_id, :tipo_dte]
  validates_presence_of :fch_venc, :rut_emisor, :rzn_soc, :giro_emis, :acteco, :rut_recep, :mnt_neto
  validates_presence_of :mnt_total, :account_id, :invoice_id
  validate :folio_validations
  
  before_create :fix_rut_k
  after_save :send_to_provider_for_process 
  
  scope :not_processed, ->() {where.not(processed: true)}
  scope :processing, ->() {where.not(processed: true).last}
  scope :e_invoice, ->() {where(tipo_dte: [33, 34])}
  scope :e_invoices, ->() {where(tipo_dte: [33, 34])}
  scope :dte_ncs, ->() {where(tipo_dte: 61)}
  
  def self.prepare_from_invoice(invoice, tipo_dte=nil)
    return process_credit_note(invoice) if tipo_dte == 61
    process_invoice(invoice)
  end
  
  def self.suggest_nc_folio(account_id)
    last_folio_for_nc(account_id) + 1
  end
  
  def self.last_folio_for_nc(account_id)
    account = Account.find(account_id)
    account.last_used_dte_nc_number
  end
  
  def self.get_last_nc_for_account(account_id)
    where(account_id: account_id).dte_ncs.order("folio desc").limit(1).first
  end
  
  def dte_type
    return DTE_TYPES[tipo_dte] unless is_dte_nc?
    nc_type
  end
  
  def is_dte_nc?
    tipo_dte == 61
  end
  
  def nc_type
    return DTE_TYPES[tipo_dte] if mnt_neto == invoice.dte_invoice.mnt_neto
    DTE_TYPES["61b"]
  end
  
  def ok?
    return error_log.nil? && processed?
  end
  
  def status
    return "Procesado" if ok?
    return "Procesando" if !processed?
    return "Error de procesamiento" if !ok?
  end
  
  def result_message
    return DTE_OK_MESSAGE if ok?
    return DTE_FAILED_MESSAGE
  end
  
  private
  
  def fix_rut_k
    self.rut_emisor = rut_emisor.gsub(/k$/, "K")
    self.rut_recep = rut_recep.gsub(/k$/, "K")
  end
  
  def send_to_provider_for_process
    return if processed?
    DteProvider.delay(run_at: DTE_CHECK_INTERVAL_SECONDS.from_now).process(self, "provider_process_response")
  end
  
  def provider_process_response(hash = {})
    self.update_attributes hash
    notify_invoice if processed?
  end
  
  def notify_invoice
    invoice.record_dte_result(self)
  end
  
  
  def folio_validations
    return validate_invoice_status if new_record?
  end
  
  def validate_invoice_status
    errors.add(:invoice, "La factura no puede ser ni borrador o pagada") unless (invoice.active? || invoice.cancelled?)
  end
  
  def self.process_invoice(invoice)
    new_attributes = translate_attributes(invoice)
    # Change code if taxed
    new_attributes["tipo_dte"] = invoice.taxed? ? 33 : 34
    # Because the Hash can have both calls to net_total
    if new_attributes["tipo_dte"] == 33
      new_attributes["mnt_neto"] = new_attributes["mnt_total"]
      new_attributes["mnt_exe"] = 0
    end
    new_attributes
  end
  
  def self.process_credit_note(invoice)
    return nc_attributes_for_cancelled(invoice) if invoice.cancelled?
    nc_attributes_for_price_change(invoice)
  end
  
  def self.nc_attributes_for_cancelled(invoice)
    attrs = invoice.dte_invoice.dup.attributes
    attrs = attributes_for_nc(attrs)
    attrs["cod_ref"] = 1
    attrs["razon_ref"] = "ANULA DOCUMENTO DE LA REFERENCIA - Fact.Electronica N° #{attrs["folio_ref"]} del #{invoice.dte_invoice.fch_emis.to_s(:db)}"
    attrs
  end
  
  def self.nc_attributes_for_price_change(invoice)
    attrs = process_invoice(invoice)
    attrs = attributes_for_nc(attrs)
    attrs["cod_ref"] = 3
    attrs["razon_ref"] = "SE CORRIGE MONTO DE LA REFERENCIA - Fact.Electronica N° #{attrs["folio_ref"]} del #{invoice.dte_invoice.fch_emis.to_s(:db)}"
    if invoice.dte_invoice.tipo_dte == 33
      attrs["mnt_neto"] = attrs["mnt_total"]
      attrs["mnt_exe"] = 0
    end
    attrs
  end
  
  def self.attributes_for_nc(attrs)
    invoice = Invoice.find(attrs["invoice_id"])
    attrs["tipo_dte"] = 61
    attrs["error_log"] = nil
    attrs["fch_emis"] = Date.today
    attrs["fch_venc"] = attrs["fch_emis"] + 30
    attrs["folio"] = suggest_nc_folio(attrs["account_id"])
    attrs["pdf_url"] = nil
    attrs["processed"] = false
    attrs["folio_ref"] = invoice.dte_invoice.folio
    attrs["fch_ref"] = invoice.dte_invoice.fch_emis
    attrs["tpo_doc_ref"] = invoice.dte_invoice.tipo_dte
    attrs
  end
  
  def self.translate_attributes(invoice)
    dte_tmp = {}
    INVOICE_DTE_MAPPINGS.each do |k,v|
      dte_tmp[v] = invoice.send(k)
    end
    dte_tmp
  end
  
end
