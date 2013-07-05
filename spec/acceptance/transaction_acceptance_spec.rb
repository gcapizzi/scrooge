require 'spec_helper'

require 'rack/test'

require './app/models'
require './app/app'

describe Scrooge::App do
  include Rack::Test::Methods

  let(:app) { Scrooge::App }

  before do
    Scrooge::Models::Account.dataset.destroy
    Scrooge::Models::Transaction.dataset.destroy
    @account = Scrooge::Models::Account.create(name: 'account')
    (1..3).each do |i|
      transaction = Scrooge::Models::Transaction.create(description: "transaction #{i}", amount: BigDecimal.new('12.34'))
      @account.add_transaction(transaction)
    end
  end

  describe 'GET /accounts/:account_id/transactions' do
    it 'returns all transactions from the account' do
      get "/accounts/#{@account.id}/transactions"
      expect(last_response.status).to eq(200)
      transactions_json = parse_json(last_response.body)[:transactions]
      expect(transactions_json.count).to eq(3)
    end
  end
end
