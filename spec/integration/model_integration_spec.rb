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

    it 'has many transactions' do
      expect(Account.new('')).to respond_to(:transactions)
    end

    it 'is wired correctly' do
      account = Account.new('test account')
      3.times { |i| account.transactions << Transaction.new("test transaction #{i}", i) }
      account.save

      expect(Account.get(account.id)).to eq(account)
      expect(account.transactions.count).to eq(3)
    end
  end

  describe Transaction do
    it 'belongs to an account' do
      expect(Transaction.new('', 0)).to respond_to(:account)
    end
  end

end
