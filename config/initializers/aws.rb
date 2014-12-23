# config/initializers/aws.rb
require 'aws-sdk'
# Rails.configuration.aws is used by AWS, Paperclip, and S3DirectUpload
Rails.configuration.aws = YAML.load(ERB.new(File.read("#{Rails.root}/config/aws.yml")).result)[Rails.env].symbolize_keys!
AWS.config(logger: Rails.logger)
AWS.config(Rails.configuration.aws)
 
# config/initializers/paperclip.rb
#if Rails.env.production?
  Paperclip::Attachment.default_options.merge!(
    url:                  ':s3_domain_url',
    path:                 ':class/:attachment/:id/:style/:filename',
    storage:              :s3,
    s3_credentials:       Rails.configuration.aws,
    s3_protocol:          'https',
    s3_headers:            lambda { |attachment|
                            {
                              'Cache-Control' => 'max-age=315576000',
                              'Expires' => 10.years.from_now.httpdate,
                              'Content-Disposition' => "attachment;",
                            }
                          }
  )
# else
#   Paperclip::Attachment.default_options.merge!(
#     url:                 "/storage/#{Rails.env}/:class/:attachment/:id/:style/:filename",
#   )
# end
 
#config/initializers/s3_direct_upload.rb
S3DirectUpload.config do |c|
  c.access_key_id     = Rails.configuration.aws[:access_key_id]
  c.secret_access_key = Rails.configuration.aws[:secret_access_key]
  c.bucket            = Rails.configuration.aws[:bucket]
  c.region            = "s3"
end