require 'sinatra'
require 'dm-serializer'
require 'rabl'
require_relative 'lib/model'

module Scrooge

  configure :development do
    DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/scrooge.db")
  end

  configure :test do
    DataMapper.setup(:default, 'sqlite::memory:')
  end

  helpers do
    def rabl(template, options = {}, locals = {})
      Rabl.register!
      content_type 'application/json'
      options = { format: 'json' }.merge options
      render :rabl, template, options, locals
    end
  end

  get '/accounts' do
    @accounts = Account.all
    rabl :accounts
  end

  get '/accounts/:id' do |id|
    @account = Account.get(id)
    return status 404 if @account.nil?
    rabl :account
  end

  put '/accounts/:id' do |id|
    @account = Account.first_or_create(id: id)
    @account.name = params[:name]

    return status 400 unless @account.valid?

    @account.save
    rabl :account
  end

  post '/accounts' do
    @account = Account.create(params)
    return status 400 unless @account.saved?
    rabl :account
  end

  delete '/accounts/:id' do |id|
    @account = Account.get(id)
    return status 404 if @account.nil?

    if @account.destroy
      rabl :account
    else
      status 500
    end
  end

end
