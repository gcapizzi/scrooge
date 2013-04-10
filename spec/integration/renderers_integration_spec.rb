require 'spec_helper'

require './app/models'
require './app/renderers'

DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!

module Scrooge

  describe AccountJsonRenderer do
    let(:accounts) { (1..3).map { Scrooge::Account.make(:valid) } }
    let(:accounts_json) do
      {
        accounts: accounts.map do |account|
          attrs = account.attributes
          attrs[:transaction_ids] = account.transactions.map { |t| t.id }
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
      it 'renders an account list correctly' do
        expect(renderer.render_list(accounts)).to eq(accounts_json.to_json)
      end
    end
  end
end
