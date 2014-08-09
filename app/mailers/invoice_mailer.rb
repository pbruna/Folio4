class InvoiceMailer < ActionMailer::Base
  layout 'mailer_default'
  
  def activation_notification(invoice)
    @invoice = Invoice.find(invoice.id, include: [:company, :contact, :account])
    @account = @invoice.account
    @contact = @invoice.contact
    
    mail to: @contact.email, subject: "#{@account.name} ha emitido una nueva factura para tu empresa."
  end
end
