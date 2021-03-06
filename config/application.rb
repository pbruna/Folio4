require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Folio
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.autoload_paths += %W(#{config.root}/lib)
    
    # Muestra las paginas personalizadas de errores
    config.exceptions_app = ->(env) { ExceptionController.action(:show).call(env) }
    config.action_dispatch.rescue_responses["BadTaste"] = :bad_request
    config.assets.precompile += %w(devise.css flat-ui.css public.css)

    
    # This is for bootstrap-sass
    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
    config.assets.paths << "#{Rails.root}/app/assets/fonts"
    config.assets.paths << "#{Rails.root}/app/assets/images"
    
    config.i18n.enforce_available_locales = false
    config.i18n.available_locales = ["es-CL"]
    config.i18n.default_locale = :'es-CL'
    
    config.to_prepare do
      Devise::Mailer.layout "mailer_default"
    end
    
    
  end
end
