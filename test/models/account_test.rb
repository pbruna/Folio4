require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  def setup
    @account = Account.new(:name => "Masev", :subdomain => "masev")
    @plan = Plan.new(:name => "trial")
    @plan.save
  end

  def teardown
    @account.destroy
    @plan.destroy
  end

  test "should not create account without a user" do
    assert_no_difference "Account.count" do
      @account.save
    end
  end

  test "after create the account should have an owner" do
    user = @account.users.build
    user.email = "test@test.com"
    user.password = "kdldlkdkdkd"
    assert(@account.save, "Account not saved")
    assert(@account.owner, "Account has not owner")
  end

  test "add user to account should not change owner" do
    user = @account.users.build
    user.email = "test@test.com"
    user.password = "kdldlkdkdkd"
    assert(@account.save, "Account not saved")
    user2 = @account.users.build
    user2.email = "test@testa.com"
    user2.password = "kdldlkdkdkd"
    @account.save
    assert_equal(user.id, @account.owner_id)
  end
  
  test "the new account should get the trial plan" do
    user = @account.users.build
    user.email = "test@test.com"
    user.password = "kdldlkdkdkd"
    assert(@account.save, "Account not saved")
    trial_plan = 1
    assert_equal(trial_plan, @account.plan_id)
  end
  
  test "should return if subdomain is available" do
    user = @account.users.build
    user.email = "test@test.com"
    user.password = "kdldlkdkdkd"
    @account.save
    assert(!Account.subdomain_available?("masev"), "Should not be available")
    assert(Account.subdomain_available?("pepito"), "Should be available")
  end
  
  test "should return if account has data" do
    @account.save
    assert(!@account.has_data?, "Should not have data because is new account")
  end
  
  test "account.owner_name should return a string" do
    user = @account.users.build
    user.email = "test@test.com"
    user.password = "kdldlkdkdkd"
    assert(@account.save, "Account not saved")
    assert_not_nil(@account.owner_name)
  end
  
  test "check for completeness of account contact info" do
    @account.save
    assert(!@account.contact_info_complete?, "No deberia estar completa")
  end
  
  test "account subdmain can not be www" do
    user = @account.users.build
    user.email = "test@test.com"
    user.password = "kdldlkdkdkd"
    @account.subdomain = "WwW"
    assert(!@account.save, "Account saved")
  end
  
  test "account subdmain can not be app" do
    user = @account.users.build
    user.email = "test@test.com"
    user.password = "kdldlkdkdkd"
    @account.subdomain = "APp"
    assert(!@account.save, "Account saved")
  end

end
