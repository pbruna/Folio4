require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "user should be unique to account" do
    user1 = User.new(:email => "pepito@pablo.com", :account_id => 2, :password => "dkdkandkajdnka")
    user2 = User.new(:email => "pepito@pablo.com", :account_id => 2, :password => "dkdkandkajdnka")
    user3 = User.new(:email => "pepito@pablo.com", :account_id => 3, :password => "dkdkandkajdnka")
    assert(user1.save, "User 1 should be created")
    assert(!user2.save, "User 2 should not be created")
    assert(user3.save, "User 3 should be created")
  end
  
  test "owner user can't be erased" do
    @plan = Plan.new(:name => "trial")
    @plan.save
    @account = Account.new(:name => "test", :subdomain => "test")
    user = @account.users.build
    user.email = "test@test.com"
    user.password = "kdldlkdkdkd"
    assert(@account.save, "Account not saved")
    assert(@account.owner, "Account has not owner")
    assert(!user.destroy, "User shouldn't be erased")
  end

end
