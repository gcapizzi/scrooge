require 'spec_helper'

require './app/models'
require './app/renderers'

DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!

module Scrooge

  describe AccountJsonRenderer do
    let(:properties) { { id: 1, name: 'an account' } }
    let(:transaction_ids) { [1, 2, 3] }
    let(:transactions) { transaction_ids.map { |id| Transaction.new(id: id) } }
    let(:account) do
      account = Account.new(properties)
      account.transactions = transactions
      account
    end
    let(:account_list) { [account] }
    let(:account_map) do
      { account: properties.merge(transaction_ids: transaction_ids) }
    end
    let(:account_json) { account_map.to_json }
    let(:account_list_json) { { accounts: [account_map] }.to_json }
    let(:renderer) { AccountJsonRenderer.new }

    describe '#render' do
      it 'renders a single account correctly' do
        expect(renderer.render(account)).to eq(account_json)
      end
    end

    describe '#render_list' do
      it 'renders an account list correctly' do
        expect(renderer.render_list(account_list)).to eq(account_list_json)
      end
    end
  end
end
