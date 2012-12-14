require 'sinatra'
require 'sinatra/json'
require 'dm-serializer'
require_relative 'model'

DataMapper.setup(:default, 'sqlite:///Users/giuseppe/Downloads/scrooge.db')

module Scrooge

  set :json_encoder, :to_json

  get '/accounts' do
    json Account.all
  end

  get '/accounts/:id' do |id|
    account = Account.get(id)
    if account.nil?
      status 404
    else
      json account
    end
  end
end
