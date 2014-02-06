require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @account = Account.new(:name => "Masev", :subdomain => "masev")
    @plan = Plan.new(:name => "trial")
    @plan.save
  end
  
  test "suggested number should return the next invoice number" do
    last_invoice = @account.invoices.last
    invoice = @account.invoices.new
    assert_equal(1, invoice.suggested_number)
  end
  
end
