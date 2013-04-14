require 'spec_helper'

require 'rack/test'

require './app/models'
require './app/app'

describe Scrooge do
  include Rack::Test::Methods

  let(:app) { Scrooge::App }

  before do
    DataMapper.auto_migrate!
    @accounts = (1..3).map { Scrooge::Account.gen(:valid) }
    @account = @accounts.first
    @accounts_json = {
      accounts: @accounts.map do |a|
        attrs = a.attributes
        attrs[:transaction_ids] = a.transactions.map { |t| t.id }
        attrs
      end
    }
    @account_json = { account: @accounts_json[:accounts].first }
    @transactions_json = {
      transactions: @account.transactions.map do |t|
        attrs = t.attributes
        attrs[:amount] = t.amount.to_s('F')
        attrs
      end
    }
  end

  describe 'GET /accounts' do
    it 'returns all accounts' do
      get '/accounts'
      expect(last_response.status).to eq(200)
      expect(parse_json(last_response.body)).to eq(@accounts_json)
    end
  end

  describe 'GET /accounts/:id' do
    context 'when the account exists' do
      it 'returns the specified account' do
        get "/accounts/#{@account.id}"
        expect(last_response.status).to eq(200)
        expect(parse_json(last_response.body)).to eq(@account_json)
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

          put "/accounts/#{@account.id}", name: new_name
          expect(last_response.status).to eq(200)

          get "/accounts/#{@account.id}"
          account_json = parse_json(last_response.body)[:account]
          expect(account_json[:name]).to eq(new_name)
        end
      end

      context 'when params are invalid' do
        it 'returns a 406 Not Acceptable and doesn\'t update the account' do
          put "/accounts/#{@account.id}", name: ''
          expect(last_response.status).to eq(406)
          expect(last_response.body).to be_empty

          get "/accounts/#{@account.id}"
          expect(last_response.status).to eq(200)
          account_json = parse_json(last_response.body)[:account]
          expect(account_json[:name]).not_to be_empty
        end
      end
    end

    context 'when the account doesn\'t exist' do
      context 'when the params are valid' do
        it 'creates a new account' do
          new_name = 'new account name'

          put '/accounts/123', name: new_name
          expect(last_response.status).to eq(201)
          account_json = parse_json(last_response.body)[:account]
          expect(account_json[:id]).to eq(123)
          expect(account_json[:name]).to eq(new_name)

          get '/accounts/123'
          expect(last_response.status).to eq(200)
          account_json = parse_json(last_response.body)[:account]
          expect(account_json[:name]).to eq(new_name)
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
        account_json = parse_json(last_response.body)[:account]
        expect(account_json[:name]).to eq('new account name')

        get '/accounts'
        expect(last_response.status).to eq(200)
        accounts_json = parse_json(last_response.body)[:accounts]
        expect(accounts_json.count).to eq(4)
      end
    end

    context 'when params are invalid' do
      it 'returns a 406 Not Acceptable and doesn\'t create an account' do
        post '/accounts', name: ''
        expect(last_response.status).to eq(406)
        expect(last_response.body).to be_empty

        get '/accounts'
        expect(last_response.status).to eq(200)
        accounts_json = parse_json(last_response.body)[:accounts]
        expect(accounts_json.count).to eq(3)
      end
    end
  end

  describe 'DELETE /accounts/:id' do
    context 'when the account exists' do
      it 'deletes the account' do
        delete "/accounts/#{@account.id}"
        expect(last_response.status).to eq(200)

        account_json = parse_json(last_response.body)[:account]
        expect(account_json[:id]).to eq(@account.id)
        expect(account_json[:name]).to eq(@account.name)

        get "/accounts/#{@account.id}"
        expect(last_response.status).to eq(404)

        get '/accounts'
        expect(last_response.status).to eq(200)
        accounts_json = parse_json(last_response.body)[:accounts]
        expect(accounts_json.count).to eq(2)
      end
    end

    context 'when the account doesn\'t exist' do
      it 'returns 404' do
        delete '/accounts/123'
        expect(last_response.status).to eq(404)
      end
    end
  end

  describe 'GET /accounts/:id/transactions' do
    context 'when the account exists' do
      it 'lists account transactions' do
        get "/accounts/#{@account.id}/transactions"
        expect(last_response.status).to eq(200)

        transactions_json = parse_json(last_response.body)
        expect(transactions_json).to eq(@transactions_json)
      end
    end

    context 'when the account doesn\'t exist'
  end
end
