require 'spec_helper'

require 'rack/test'

require './app/models'
require './app/app'

describe 'Scrooge::App'  do
  include Rack::Test::Methods

  before do
    Scrooge::Models::Account.dataset.destroy
    Scrooge::Models::Transaction.dataset.destroy
  end

  let(:app) { Scrooge::App }
  let!(:account) { Fabricate(:account) }

  describe 'GET /accounts/:account_id/transactions' do
    it 'returns all transactions from the account' do
      get "/accounts/#{account.id}/transactions"
      expect(last_response.status).to eq(200)
      transactions_json = parse_json(last_response.body)[:transactions]
      expect(transactions_json.count).to eq(3)
    end
  end
end
