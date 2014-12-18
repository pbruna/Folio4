# config/initializers/gdexpress.rb

Rails.configuration.gdexpress = YAML.load(ERB.new(File.read("#{Rails.root}/config/gdexpress.yml")).result)[Rails.env].symbolize_keys!
