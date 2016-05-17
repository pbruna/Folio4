require 'test_helper'

# Placeholder
class MoneyAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @visa = money_accounts(:visa)
    @corriente = money_accounts(:corriente)
  end

  test 'self.types responds to methods' do
    random_type = MoneyAccount.types.sample
    assert random_type.name, 'respond to name'
    assert random_type.id, 'respond to id'
  end

  test 'credit? responde segun el type_id' do
    assert @visa.credit?, 'visa tiene credito'
    assert !@corriente.credit?, 'corriente no tiene credito'
  end

end
