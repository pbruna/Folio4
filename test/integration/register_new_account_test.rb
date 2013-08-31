require 'test_helper'

class RegisterNewAccountTest < ActionDispatch::IntegrationTest

  def setup
    @plan = Plan.new(:name => "trial")
    @plan.save
  end

  def teardown
    @plan.destroy
  end
  
  test "create account" do
    visit '/accounts/new'
    assert page.has_content?('comenzar'), "Fallo"
    fill_in 'Email', :with => "pbruna@masev.cl"
    fill_in 'Contraseña', :with => "123456"
    fill_in 'Empresa', :with => "masev"
    fill_in 'account_subdomain', :with => "masev"
    click_button "Comenzar trial"
    assert page.current_url == "http://masev.example.com/", "No ingreso despues de crear la cuenta"
    # Empty account
    assert page.has_content?("Conoce la salud de tu negocio"), "No carga el contenido sin datos"
  end
  

end
