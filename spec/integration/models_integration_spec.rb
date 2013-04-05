require 'spec_helper'
require 'spec_fixtures'

require './app/models'

DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!

module Scrooge

  describe Account do
    it "doesn't allow an empty name" do
      account = Account.make(:invalid)
      expect(account).not_to be_valid
    end

    it 'is wired correctly' do
      account = Account.gen(:valid)
      account.transactions.save
      account_on_db = Account.get(account.id)
      expect(account_on_db).to eq(account)
      expect(account_on_db.transactions.count).to eq(3)
    end
  end

  describe Transaction do
    it 'is wired correctly' do
      description = "test transaction"
      amount = BigDecimal.new("12.34")
      transaction = Transaction.make(description: description, amount: amount)
      account = Account.gen(:valid)
      transaction.account = account
      transaction.save
      transaction_on_db = Transaction.get(transaction.id)
      expect(transaction_on_db.description).to eq(description)
      expect(transaction_on_db.amount).to eq(amount)
      expect(transaction_on_db.account).to eq(account)
    end
  end

end
