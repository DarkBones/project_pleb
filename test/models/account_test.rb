# == Schema Information
#
# Table name: accounts
#
#  id           :bigint           not null, primary key
#  balance      :integer          default(0)
#  user_id      :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  name         :string(255)      not null
#  description  :string(255)
#  position     :integer
#  currency     :string(255)      not null
#  is_default   :boolean
#  account_type :string(255)      default("spend")
#  hash_id      :string(255)
#  is_disabled  :boolean          default(FALSE)
#

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test "Get accounts" do
    current_user = users(:bas)
    accounts = Account.get_accounts(current_user)

    assert accounts.length == 8, format_error("Unexpected number of accounts", 8, accounts.length)
    assert accounts.first.balance == 200, format_error("Unexpected total balance", 200, accounts.first.balance)
  end
    
  test "Save account without name" do
    current_user = users(:bas)
    account = current_user.accounts.build({:balance => 200})

    assert_not account.save, format_error("Saved the account without a name")
  end

  test "Save account without balance" do
    current_user = users(:bas)
    account = current_user.accounts.build({:name => 'test account without balance', :currency => 'EUR'})

    assert account.save, format_error("Could not save account without specifying the balance\n#{account.errors.messages}")
    assert account.balance == 0, format_error("Unexpected default account balance", 0, account.balance)
  end

  test "Create duplicate account" do
    current_user = users(:bas)

    a1 = current_user.accounts.build({:name => 'test duplicate', :currency => 'EUR'})
    a2 = current_user.accounts.build({:name => 'test duplicate', :currency => 'EUR'})

    assert a1.save
    assert_not a2.save, format_error("Created duplicate account name")
  end

  test "Create new account" do
    current_user = users(:bas)
    params = {name: 'New account', balance: 500, currency: 'EUR', description: 'Test description'}

    account = Account.create_new(params, current_user)

    assert account.name == 'New account', format_error("Unexpected account name", 'New account', account.name)
    assert account.balance == 50000, format_error("Unexpected account balance", 50000, account.balance)
    assert account.currency == 'EUR', format_error('Unexpected account currency', 'EUR', account.currency)
    assert account.description == 'Test description', format_error('Unexpected account description', 'Test description', account.description)
  end

  test "Get currency" do
    current_user = users(:bas)
    account = current_user.accounts.first

    currency = Account.get_currency(account)
    assert currency.is_a?(Money::Currency), format_error('Unexpected currency class', 'Money::Currency', currency.class.name)
  end
end
