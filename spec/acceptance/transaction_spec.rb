require 'spec_helper'

require 'rack/test'

require './app/models'
require './app/app'

describe 'Scrooge::App'  do
  include Rack::Test::Methods

  let(:app) { Scrooge::App }

  describe 'GET /accounts/:account_id/transactions' do
    context 'when the account exists' do
      let!(:account) { Fabricate(:account) }

      it 'returns all transactions from the account' do
        get "/accounts/#{account.id}/transactions"
        expect(last_response.status).to eq(200)
        transactions_json = parse_json(last_response.body)[:transactions]
        expect(transactions_json.count).to eq(3)
      end
    end

    context 'when the account doesn\'t exist' do
      it 'returns an empty list of transactions' do
        get '/accounts/123/transactions'
        transactions_json = parse_json(last_response.body)[:transactions]
        expect(transactions_json).to be_empty
      end
    end
  end
end
