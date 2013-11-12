require 'test_helper'

class CompanyTest < ActiveSupport::TestCase

  def setup
    @company = Company.new(:name => "Acme", :address => "Test", :province => "Test", :city => "Test")
  end


  def teardown
    @company.destroy
  end

  test "should have a valid rut" do
    assert_no_difference('Company.count') do
      @company.rut = "13.834.853-8"
      @company.save
    end
    @company.rut = "13.834.853-9"
    assert(@company.save, "No se guardo")
  end

end
