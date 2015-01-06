ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'
require 'mocha/mini_test'
require 'webmock/minitest'

require 'fake_gd_express'


class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...
  
  def fake_data
    @plan = Plan.new(:name => "trial")
    @plan.save
    @account = Account.new(
                            :name => "Masev", :subdomain => "maseva", :rut => "76.530.890-k", 
                            address: "Eliodro Yañez 810", city: "Santiago",
                            e_invoice_enabled: true, e_invoice_resolution_date: "2014/01/01",
                            industry_code: 10398, industry: "Servicios Informaticos"
                            )
    @user = @account.users.new(email: "pbruna@gmail.com", password: "172626292")
    @account.save
    @user.save
    @company = Company.new(name: "Acme", rut: "13.834.853-9", address: "Eliodro Yañez 810", province: "Providencia", city: "Santiago", account_id: @account.id, industry: "Servicios Informaticos" )
    @company.save
    @contact = Contact.new(company_id: @company.id, name: "Patricio", email: "pbruna@itlinux.cl")
    @contact.save
    @invoice = @account.invoices.new(number: 28, subject: "Prueba de Factura", 
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
  
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
end

class Hash
  def &(other)
    result = {}
    each {|k, v| result[k] = other[k] if other[k] != v }
    result
  end
end