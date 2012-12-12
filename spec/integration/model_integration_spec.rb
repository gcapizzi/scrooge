require 'spec_helper'
require_relative '../../lib/model'

DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!

module Scrooge

  describe Account do
    it "doesn't allow an empty name" do
      account = Account.new('')
      expect(account).not_to be_valid
    end

    it 'is wired correctly' do
      account = Account.new('test account')
      3.times { |i| account.transactions << Transaction.new("test transaction #{i}", i) }
      account.save

      account_on_db = Account.get(account.id)
      expect(account_on_db).to eq(account)
      expect(account_on_db.transactions.count).to eq(3)
    end
  end

  describe Transaction do
    it 'is wired correctly' do
      transaction = Transaction.new('test transaction', 12.34)
      account = Account.new('test account')
      transaction.account = account
      transaction.save

      transaction_on_db = Transaction.get(transaction.id)
      expect(transaction_on_db).to eq(transaction)
      expect(transaction_on_db.account).to eq(account)
    end
  end

end
