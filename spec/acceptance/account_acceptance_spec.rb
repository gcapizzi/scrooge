require 'spec_helper'

require 'rack/test'

require './model'
require './app'

describe Scrooge do
  include Rack::Test::Methods

  let(:app) { Scrooge::App }
  let(:accounts) {{
      accounts: (1..3).map do |i|
        { account: { id: i, name: "test account #{i}" } }
      end
  }}

  before do
    DataMapper.auto_migrate!
    accounts[:accounts].each do |account|
      Scrooge::Account.create(account[:account])
    end
  end

  describe 'GET /accounts' do
    it 'returns all accounts' do
      get '/accounts'
      expect(last_response).to be_ok
      expect(parse_json(last_response)).to eq(accounts)
    end
  end

  describe 'GET /accounts/:id' do
    context 'when the account exists' do
      it 'returns the specified account' do
        get '/accounts/1'
        expect(last_response).to be_ok
        expect(parse_json(last_response)).to eq(accounts[:accounts].first)
      end
    end

    context 'when the account doesn\'t exist' do
      it 'returns 404' do
        get '/accounts/123'
        expect(last_response).not_to be_ok
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
          expect(last_response).to be_ok

          get '/accounts/1'
          account = parse_json(last_response)[:account]
          expect(account[:name]).to eq(new_name)
        end
      end

      context 'when params are invalid' do
        it 'returns a 400 Bad Request and doesn\'t update the account' do
          put '/accounts/1', name: ''
          expect(last_response.status).to eq(400)
          expect(last_response.body).to be_empty

          get '/accounts/1'
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
          expect(last_response).to be_ok
          account = parse_json(last_response)[:account]
          expect(account[:id]).to eq(123)
          expect(account[:name]).to eq(new_name)

          get '/accounts/123'
          expect(last_response).to be_ok
          account = parse_json(last_response)[:account]
          expect(account[:name]).to eq(new_name)
        end
      end

      context 'when params are invalid' do
        it 'returns a 400 Bad Request and doesn\'t create an account' do
          put '/accounts/123', name: ''
          expect(last_response.status).to eq(400)
          expect(last_response.body).to be_empty

          get '/accounts/123'
          expect(last_response).not_to be_ok
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
        expect(last_response).to be_ok
        account = parse_json(last_response)[:account]
        expect(account[:name]).to eq('new account name')

        get '/accounts'
        expect(parse_json(last_response)[:accounts].count).to eq(4)
      end
    end

    context 'when params are invalid' do
      it 'returns a 400 Bad Request and doesn\'t create an account' do
        post '/accounts', name: ''
        expect(last_response.status).to eq(400)
        expect(last_response.body).to be_empty

        get '/accounts'
        expect(parse_json(last_response)[:accounts].count).to eq(3)
      end
    end
  end

  describe 'DELETE /accounts/:id' do
    context 'when the account exists' do
      it 'deletes the account' do
        delete '/accounts/1'
        expect(last_response).to be_ok

        account = parse_json(last_response)[:account]
        expect(account[:id]).to eq(1)
        expect(account[:name]).to eq("test account 1")

        get '/accounts/1'
        expect(last_response.status).to eq(404)

        get '/accounts'
        expect(parse_json(last_response)[:accounts].count).to eq(2)
      end
    end

    context 'when the account doesn\'t exist' do
      it 'returns 404' do
        delete '/accounts/123'
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(404)
      end
    end
  end
end
