require 'spec_helper'
require 'rack/test'
require 'data_mapper'
require 'json'
require_relative '../../lib/model'
require_relative '../../lib/app'

describe Scrooge do
  include Rack::Test::Methods

  let(:app) { Sinatra::Application }
  let(:accounts) { (1..3).map { |i| { id: i, name: "test account #{i}" }}}

  before do
    accounts.each { |account| Scrooge::Account.create(account) }
  end

  after do
    Scrooge::Account.destroy
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
        expect(parse_json(last_response)).to eq(accounts.first)
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
          new_name = 'new test account name'

          put '/accounts/1', name: new_name
          expect(last_response).to be_ok

          get '/accounts/1'
          account = parse_json(last_response)
          expect(account[:name]).to eq(new_name)
        end

        context 'when params are invalid' do
          it 'returns a 400 Bad Request and doesn\'t update the account' do
            put '/accounts/1', name: ''
            expect(last_response.status).to eq(400)
            expect(last_response.body).to be_empty

            get '/accounts/1'
            account = parse_json(last_response)
            expect(account[:name]).not_to be_empty
          end
        end
      end
    end

    context 'when the account doesn\'t exist' do
      context 'when the params are valid' do
        it 'creates a new account' do
          new_name = 'new test account name'

          put '/accounts/123', name: new_name
          response = parse_json(last_response)
          expect(last_response).to be_ok
          expect(response[:id]).to eq(123)
          expect(response[:name]).to eq(new_name)

          get '/accounts/123'
          response = parse_json(last_response)
          expect(last_response).to be_ok
          expect(response[:name]).to eq(new_name)
        end
      end

      context 'when params are invalid' do
        it 'returns a 400 Bad Request and doesn\'t create the account' do
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

  def parse_json(json_response)
    JSON.parse(json_response.body, symbolize_names: true)
  end
end
