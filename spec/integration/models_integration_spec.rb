require 'spec_helper'

require './app/models'

module Scrooge
  module Models

    describe Account do
      it "doesn't allow an empty name" do
        account = Fabricate(:account, name: '')
        expect(account).not_to be_valid
        expect(account.errors.on(:name)).to include("can't be empty")
      end

      it 'is wired correctly' do
        account = Fabricate(:account)
        account_on_db = Account[account.id]
        expect(account_on_db).to eq(account)
        expect(account_on_db.transactions.count).to eq(3)
      end
    end

    describe Transaction do
      it 'is wired correctly' do
        description = 'test transaction'
        amount = BigDecimal.new('12.34')
        transaction = Fabricate.build(:transaction, description: description, amount: amount)
        account = Fabricate(:account)
        transaction.account = account
        transaction.save
        transaction_on_db = Transaction[transaction.id]
        expect(transaction_on_db.description).to eq(description)
        expect(transaction_on_db.amount).to eq(amount)
        expect(transaction_on_db.account).to eq(account)
      end
    end

  end
end
