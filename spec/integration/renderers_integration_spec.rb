require 'spec_helper'

require './app/models'
require './app/renderers'

DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!

module Scrooge

  describe AccountJsonRenderer do
    let(:accounts) { (1..3).map { Scrooge::Account.gen(:valid) } }
    let(:accounts_json) do
      {
        accounts: accounts.map do |a|
          attrs = a.attributes
          attrs[:transaction_ids] = a.transactions.map { |t| t.id }
          { account: attrs }
        end
      }
    end
    let(:account) { accounts.first }
    let(:account_json) { accounts_json[:accounts].first }
    let(:renderer) { AccountJsonRenderer.new }

    describe '#render' do
      it 'renders a single account correctly' do
        expect(renderer.render(account)).to eq(account_json.to_json)
      end
    end

    describe '#render_list' do
      it 'renders an accounts list correctly' do
        expect(renderer.render_list(accounts)).to eq(accounts_json.to_json)
      end
    end
  end

  describe TransactionJsonRenderer do
    let(:transactions) { Scrooge::Account.gen(:valid).transactions }
    let(:transactions_json) do
      {
        transactions: transactions.map do |t|
          attrs = t.attributes
          attrs[:amount] = t.amount.to_s('F')
          { transaction: attrs }
        end
      }
    end
    let(:transaction) { transactions.first }
    let(:transaction_json) { transactions_json[:transactions].first }
    let(:renderer) { TransactionJsonRenderer.new }

    describe '#render' do
      it 'renders a single transaction correctly' do
        expect(renderer.render(transaction)).to eq(transaction_json.to_json)
      end

      it 'renders a transactions list correctly' do
        expect(renderer.render_list(transactions)).to eq(transactions_json.to_json)
      end
    end
  end
end
