require 'spec_helper'

require 'rack/test'

require './app/models'
require './app/app'

describe Scrooge::App do
  include Rack::Test::Methods

  let(:app) { Scrooge::App }

  before do
    Scrooge::Account.destroy
    @accounts = (1..3).map do |i|
      account = Scrooge::Account.create(name: "account #{i}")
      3.times do |j|
        transaction_hash = { description: "transaction #{j}",
                             amount: BigDecimal.new('12.34') }
        account.add_transaction(Scrooge::Transaction.create(transaction_hash))
      end
      account.save
      account
    end
    @account = @accounts.first
  end

  describe 'GET /accounts' do
    it 'returns all accounts' do
      get '/accounts'
      expect(last_response.status).to eq(200)
      accounts_json = parse_json(last_response.body)[:accounts]
      expect(accounts_json.count).to eq(3)
    end
  end

  describe 'GET /accounts/:id' do
    context 'when the account exists' do
      it 'returns the specified account' do
        get "/accounts/#{@account.id}"
        expect(last_response.status).to eq(200)
        expect(parse_json(last_response.body)[:accounts]).not_to be_nil
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

  describe 'PATCH /accounts/:id' do
    context 'when the account exists' do
      context 'when params are valid' do
        it 'updates the account' do
          new_name = 'new account name'

          patch "/accounts/#{@account.id}", name: new_name
          expect(last_response.status).to eq(200)

          get "/accounts/#{@account.id}"
          account_json = parse_json(last_response.body)[:accounts][0]
          expect(account_json[:name]).to eq(new_name)
        end
      end

      context 'when params are invalid' do
        it 'returns a 406 Not Acceptable and doesn\'t update the account' do
          patch "/accounts/#{@account.id}", name: ''
          expect(last_response.status).to eq(406)
          expect(last_response.body).to be_empty

          get "/accounts/#{@account.id}"
          expect(last_response.status).to eq(200)
          account_json = parse_json(last_response.body)[:accounts][0]
          expect(account_json[:name]).not_to be_empty
        end
      end
    end

    context 'when the account doesn\'t exist' do
      it 'returns 404' do
        patch '/accounts/123', name: 'some name'
        expect(last_response.status).to eq(404)
      end
    end
  end

  describe 'POST /accounts' do
    context 'when params are valid' do
      it 'creates a new account' do
        post '/accounts', name: 'new account name'
        expect(last_response.status).to eq(201)
        account_json = parse_json(last_response.body)[:accounts][0]
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

        account_json = parse_json(last_response.body)[:accounts][0]
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
end
