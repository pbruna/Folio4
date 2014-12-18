class Dte < ActiveRecord::Base

  DTE_OK_MESSAGE = "El DTE se proceso correctamente y pueden verlo en la opción DTEs de la Venta"
  DTE_FAILED_MESSAGE = "Ocurrió un problema al procesar el DTE, más información disponible en la pestaña DTEs\n\n"
  DTE_CHECK_INTERVAL_SECONDS = 30
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
    "company_address" => "dir_recep",
    "company_province" => "cmna_recep",
    "company_industry" => "giro_recep",
    "contact_name_titleize" => "contacto",
    "cond_pago" => "cond_pago",
    "net_total" => "mnt_neto",
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
  validates_presence_of :fch_venc, :rut_emisor, :rzn_soc, :giro_emis, :acteco, :rut_recep
  validates_presence_of :mnt_total, :account_id, :invoice_id, :dir_recep, :cmna_recep, :giro_recep
  validates_presence_of :mnt_neto, if: :taxed?
  validate :folio_validations
  
  before_create :fix_rut_k
  after_create :send_to_provider_for_process
  
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
  
  def check_status(status=false)
    return if status
    # Como el SII se demora en procesar los DTEs, dejamos un trabajo en Background
    DteProvider.delay(run_at: DTE_CHECK_INTERVAL_SECONDS.from_now).check_dte_status self, "status_response"
  end
  
  def pdf_file
    DteProvider.pdf_base64 self
  end
  
  def status_response(dte_status)
    update_with_dte_provider_info(dte_status) if dte_status[:processed]
    # run again if it was not processed
    check_status dte_status[:processed]
  end
  
  def update_with_dte_provider_info(dte_status)
    self.processed = dte_status[:processed]
    self.error_log = dte_status[:log] unless dte_status[:accepted]
    save
    notify_invoice
  end
  
  def is_dte_nc?
    tipo_dte == 61
  end
  
  def taxed?
    return tipo_dte == 33 if tipo_dte != 61
    return invoice.dte_invoice.tipo_dte == 33
  end
  
  def nc_type
    return DTE_TYPES[tipo_dte] if mnt_total == invoice.dte_invoice.mnt_total
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
    return DTE_FAILED_MESSAGE + "-------- LOG ------\n#{error_log}"
  end
  
  private
  
  def fix_rut_k
    self.rut_emisor = rut_emisor.gsub(/k$/, "K")
    self.rut_recep = rut_recep.gsub(/k$/, "K")
  end
  
  def send_to_provider_for_process
    # Estamos usando la conexion por DB
    # por lo tanto no enviamos nada, GDE lo viene a buscar de la db
    # Igual llamamos a provider_process_response para seguir el proceso
    provider_process_response true
  end
  
  def provider_process_response(response = false)
    raise "DTE: El DTE no se pudo enviar para ser procesado" unless response
    check_status    
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
    attrs = translate_attributes(invoice)
    # Change code if taxed
    attrs["tipo_dte"] = invoice.taxed? ? 33 : 34
    # Because the Hash can have both calls to net_total
    attrs = calc_mnts(attrs, attrs["tipo_dte"])
    attrs
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
    attrs = calc_mnts(attrs, invoice.dte_invoice.tipo_dte)
    attrs
  end
  
  def self.calc_mnts(attrs, tipo_dte)
    attrs["mnt_exe"] = 0 if tipo_dte == 33
    if tipo_dte == 34
      attrs["mnt_exe"] = attrs["mnt_total"]
      attrs["mnt_neto"] = nil
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
