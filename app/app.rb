require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'sinatra/reloader'
require 'rabl'

require './app/model'

module Scrooge

  class App < Sinatra::Base
    set :public_folder, "#{Dir.pwd}/public"

    configure :development do
      DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/scrooge.db")
      register Sinatra::Reloader
    end

    configure :test do
      enable :logging, :dump_errors, :raise_errors
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

    get '/' do
      send_file File.join(settings.public_folder, 'index.html')
    end

    get '/accounts' do
      @accounts = Account.all
      rabl :accounts
    end

    get '/accounts/:id' do |id|
      @account = Account.get(id.to_i)
      return status 404 if @account.nil?
      rabl :account
    end

    put '/accounts/:id' do |id|
      @account = Account.get(id.to_i)

      if @account.nil?
        @account = Account.create(id: params[:id].to_i, name: params[:name])
        status 201
      else
        @account.name = params[:name]
        status 304 if not @account.dirty?
        @account.save
      end

      return status 400 if not @account.valid?

      rabl :account
    end

    post '/accounts' do
      @account = Account.create(params)
      return status 400 if not @account.saved?
      status 201
      rabl :account
    end

    delete '/accounts/:id' do |id|
      @account = Account.get(id.to_i)
      return status 404 if @account.nil?

      if @account.destroy
        rabl :account
      else
        status 500
      end
    end
  end

end
