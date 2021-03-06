require 'spec_helper'

require './app/models'
require './app/renderers'

module Scrooge
  module Renderers

    shared_examples 'an accounts json renderer' do
      let(:account) { Fabricate(:account) }
      let(:accounts) { [account] }

      it 'serializes an account to JSON' do
        account_json = renderer.render(account)
        account_hash = parse_json(account_json)[:accounts].first

        expect_account_attributes(account_hash, account)
      end

      it 'serializes a collection of accounts to JSON' do
        accounts_json = renderer.render(accounts)
        account_hash = parse_json(accounts_json)[:accounts].first

        expect_account_attributes(account_hash, account)
      end

      def expect_account_attributes(attributes, account)
        expect(attributes[:id]).to eq(account.id)
        expect(attributes[:name]).to eq(account.name)
        expect(attributes[:links][:transactions].count).to eq(account.transactions.count)
        expect(attributes[:links][:transactions].first).to eq(account.transactions.first.id)
      end
    end

    shared_examples 'a transactions json renderer' do
      let(:account) { Fabricate(:account) }
      let(:transactions) { account.transactions }
      let(:transaction) { transactions.first }

      it 'serializes a transaction to JSON' do
        transaction_json = renderer.render(transaction)
        transaction_hash = parse_json(transaction_json)[:transactions].first

        expect_transaction_attributes(transaction_hash, transaction)
      end

      it 'serializes a collection of transactions to JSON' do
        transactions_json = renderer.render(transactions)
        transactions_array = parse_json(transactions_json)[:transactions]
        transaction_hash = transactions_array.first

        expect(transactions_array.count).to eq(3)
        expect_transaction_attributes(transaction_hash, transaction)
      end

      def expect_transaction_attributes(attributes, transaction)
        expect(attributes[:id]).to eq(transaction.id)
        expect(attributes[:description]).to eq(transaction.description)
        expect(attributes[:amount]).to eq(transaction.amount.to_s('F'))
        expect(attributes[:links][:account]).to eq(transaction.account.id)
      end
    end

    describe HashAccountsJsonRenderer do
      let(:renderer) { HashAccountsJsonRenderer.new }
      it_behaves_like 'an accounts json renderer'
    end

    describe HashTransactionsJsonRenderer do
      let(:renderer) { HashTransactionsJsonRenderer.new }
      it_behaves_like 'a transactions json renderer'
    end

  end
end
