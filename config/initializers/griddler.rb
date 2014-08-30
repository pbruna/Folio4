Griddler.configure do |config|
  config.processor_class = EmailProcessor # CommentViaEmail
  config.processor_method = :process # :create_comment (A method on CommentViaEmail)
  config.reply_delimiter = '-- RESPONDA SOBRE ESTA LINEA --'
  config.email_service = :mailgun # :cloudmailin, :postmark, :mandrill, :mailgun
end