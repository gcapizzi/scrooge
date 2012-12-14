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
      end
    end
  end

  def parse_json(json_response)
    JSON.parse(json_response.body, symbolize_names: true)
  end
end
