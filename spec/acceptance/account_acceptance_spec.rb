require 'spec_helper'

require 'rack/test'

require './app/models'
require './app/app'

describe Scrooge do
  include Rack::Test::Methods

  let(:app) { Scrooge::App }
  let(:accounts) do
    (1..3).map do |i|
      { id: i, name: "test account #{i}" }
    end
  end
  let(:accounts_json) do
    accounts_list = []
    transaction_ids = (1..9).to_a
    accounts.each do |account|
      account[:transaction_ids] = transaction_ids.shift(3)
      accounts_list << { account: account }
    end
    { accounts: accounts_list }
  end
  let(:transactions) do
    transactions = []
    accounts_json[:accounts].each do |account|
      account[:account][:transaction_ids].each do |id|
        transaction = {
          id: id,
          description: "test transaction #{id}",
          amount: 1.0,
          account_id: account[:account][:id]
        }
        transactions << transaction
      end
    end
    transactions
  end
  let(:transactions_json) do
    { transactions: transactions.map { |t| { transaction: t } } }
  end

  before do
    DataMapper.auto_migrate!
    accounts.each { |account| Scrooge::Account.create(account) }
    transactions.each { |transaction| Scrooge::Transaction.create(transaction) }
  end

  describe 'GET /accounts' do
    it 'returns all accounts' do
      get '/accounts'
      expect(last_response.status).to eq(200)
      expect(parse_json(last_response)).to eq(accounts_json)
    end
  end

  describe 'GET /accounts/:id' do
    context 'when the account exists' do
      it 'returns the specified account' do
        get '/accounts/1'
        expect(last_response.status).to eq(200)
        expect(parse_json(last_response)).to eq(accounts_json[:accounts].first)
      end
    end

    context 'when the account doesn\'t exist' do
      it 'returns 404' do
        get '/accounts/123'
        expect(last_response.status).to eq(404)
        expect(last_response.body).to be_empty
      end
    end
  end

  describe 'PUT /accounts/:id' do
    context 'when the account exists' do
      context 'when params are valid' do
        it 'updates the account' do
          new_name = 'new account name'

          put '/accounts/1', name: new_name
          expect(last_response.status).to eq(200)

          get '/accounts/1'
          account = parse_json(last_response)[:account]
          expect(account[:name]).to eq(new_name)
        end
      end

      context 'when params are invalid' do
        it 'returns a 406 Not Acceptable and doesn\'t update the account' do
          put '/accounts/1', name: ''
          expect(last_response.status).to eq(406)
          expect(last_response.body).to be_empty

          get '/accounts/1'
          expect(last_response.status).to eq(200)
          account = parse_json(last_response)[:account]
          expect(account[:name]).not_to be_empty
        end
      end
    end

    context 'when the account doesn\'t exist' do
      context 'when the params are valid' do
        it 'creates a new account' do
          new_name = 'new account name'

          put '/accounts/123', name: new_name
          expect(last_response.status).to eq(201)
          account = parse_json(last_response)[:account]
          expect(account[:id]).to eq(123)
          expect(account[:name]).to eq(new_name)

          get '/accounts/123'
          expect(last_response.status).to eq(200)
          account = parse_json(last_response)[:account]
          expect(account[:name]).to eq(new_name)
        end
      end

      context 'when params are invalid' do
        it 'returns a 406 Not Acceptable and doesn\'t create an account' do
          put '/accounts/123', name: ''
          expect(last_response.status).to eq(406)
          expect(last_response.body).to be_empty

          get '/accounts/123'
          expect(last_response.status).not_to eq(200)
          expect(last_response.status).to eq(404)
          expect(last_response.body).to be_empty
        end
      end
    end
  end

  describe 'POST /accounts' do
    context 'when params are valid' do
      it 'creates a new account' do
        post '/accounts', name: 'new account name'
        expect(last_response.status).to eq(201)
        account = parse_json(last_response)[:account]
        expect(account[:name]).to eq('new account name')

        get '/accounts'
        expect(last_response.status).to eq(200)
        accounts = parse_json(last_response)[:accounts]
        expect(accounts.count).to eq(4)
      end
    end

    context 'when params are invalid' do
      it 'returns a 406 Not Acceptable and doesn\'t create an account' do
        post '/accounts', name: ''
        expect(last_response.status).to eq(406)
        expect(last_response.body).to be_empty

        get '/accounts'
        expect(last_response.status).to eq(200)
        accounts = parse_json(last_response)[:accounts]
        expect(accounts.count).to eq(3)
      end
    end
  end

  describe 'DELETE /accounts/:id' do
    context 'when the account exists' do
      it 'deletes the account' do
        delete '/accounts/1'
        expect(last_response.status).to eq(200)

        account = parse_json(last_response)[:account]
        expect(account[:id]).to eq(1)
        expect(account[:name]).to eq("test account 1")

        get '/accounts/1'
        expect(last_response.status).to eq(404)

        get '/accounts'
        expect(last_response.status).to eq(200)
        accounts = parse_json(last_response)[:accounts]
        expect(accounts.count).to eq(2)
      end
    end

    context 'when the account doesn\'t exist' do
      it 'returns 404' do
        delete '/accounts/123'
        expect(last_response.status).to eq(404)
      end
    end
  end
end
