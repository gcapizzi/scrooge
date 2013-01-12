require 'sinatra'
require 'sinatra/json'
require 'dm-serializer'
require_relative 'lib/model'

DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/scrooge.db")

module Scrooge

  set :json_encoder, :to_json

  get '/accounts' do
    json Account.all
  end

  get '/accounts/:id' do |id|
    account = Account.get(id)
    return status 404 if account.nil?
    json account
  end

  put '/accounts/:id' do |id|
    account = Account.first_or_create(id: id)
    account.name = params[:name]

    return status 400 unless account.valid?

    account.save
    json account
  end

  post '/accounts' do
    account = Account.create(params)
    return status 400 unless account.saved?
    json account
  end

  delete '/accounts/:id' do |id|
    account = Account.get(id)
    return status 404 if account.nil?

    if account.destroy
      json account
    else
      status 500
    end
  end

end
