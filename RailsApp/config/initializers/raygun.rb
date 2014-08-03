Raygun.setup do |config|
  config.api_key = "DLHqcHjVC95yxCe/z8rz5Q=="
  config.filter_parameters = Rails.application.config.filter_parameters
  config.enable_reporting = Rails.env.development?
  config.silence_reporting = false
end
