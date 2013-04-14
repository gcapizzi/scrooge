require 'spec_helper'
require 'spec_fixtures'

require './app/models'
require './app/renderers'

DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!

module Scrooge

  describe AccountJsonRenderer do
    let(:renderer) { AccountJsonRenderer.new('app/views') }
    let(:account) { Account.gen(:valid) }
    let(:accounts) { [account] }

    it 'serializes an account to JSON' do
      account_json = renderer.render_object(account)
      account_hash = parse_json(account_json)[:account]

      expect(account_hash[:id]).to eq(account.id)
      expect(account_hash[:name]).to eq(account.name)
      expect(account_hash[:transaction_ids].count).to eq(3)
      expect(account_hash[:transaction_ids].first).to eq(account.transactions.first.id)
    end

    it 'serializes a collection of accounts to JSON' do
      accounts_json = renderer.render_collection(accounts)
      account_hash = parse_json(accounts_json)[:accounts].first[:account]

      expect(account_hash[:id]).to eq(account.id)
      expect(account_hash[:name]).to eq(account.name)
      expect(account_hash[:transaction_ids].count).to eq(3)
      expect(account_hash[:transaction_ids].first).to eq(account.transactions.first.id)
    end
  end

  describe TransactionJsonRenderer do
    let(:renderer) { TransactionJsonRenderer.new('app/views') }
    let(:account) { Account.gen(:valid) }
    let(:transactions) { account.transactions }
    let(:transaction) { transactions.first }

    it 'serializes a transaction to JSON' do
      transaction_json = renderer.render_object(transaction)
      transaction_hash = parse_json(transaction_json)[:transaction]

      expect(transaction_hash[:id]).to eq(transaction.id)
      expect(transaction_hash[:description]).to eq(transaction.description)
      expect(transaction_hash[:amount]).to eq(transaction.amount.to_s('F'))
      expect(transaction_hash[:account_id]).to eq(account.id)
    end

    it 'serializes a collection of transactions to JSON' do
      transactions_json = renderer.render_collection(transactions)
      transactions_array = parse_json(transactions_json)[:transactions]
      transaction_hash = transactions_array.first[:transaction]

      expect(transactions_array.count).to eq(3)
      expect(transaction_hash[:id]).to eq(transaction.id)
      expect(transaction_hash[:description]).to eq(transaction.description)
      expect(transaction_hash[:amount]).to eq(transaction.amount.to_s('F'))
      expect(transaction_hash[:account_id]).to eq(account.id)
    end
  end
end
