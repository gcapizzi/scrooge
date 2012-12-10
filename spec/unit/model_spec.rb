require 'spec_helper'
require_relative '../../lib/model'

DataMapper.setup(:default, 'sqlite::memory')

module Scrooge

  describe Account do
    describe '#initialize' do
      it "accepts an account name" do
        account_name = 'account name'
        account = Account.new(account_name)
        expect(account.name).to eq(account_name)
      end
    end

    it "doesn't allow an empty name" do
      account = Account.new('')
      expect(account).not_to be_valid
    end

    it 'has many transactions' do
      expect(Account.new('')).to respond_to(:transactions)
    end
  end

  describe Transaction do
    describe '#initialize' do
      it 'accepts a transaction description and amount' do
        description = 'a transaction description'
        amount = 12.34
        transaction = Transaction.new(description, amount)
        expect(transaction.description).to eq(description)
        expect(transaction.amount).to eq(amount)
      end
    end

    it 'belongs to an account' do
      expect(Transaction.new('', 0)).to respond_to(:account)
    end
  end

end
