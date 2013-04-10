require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'sinatra/reloader'

require './app/models'
require './app/renderers'

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

    before do
      @account_renderer = AccountJsonRenderer.new
      @transaction_renderer = TransactionJsonRenderer.new
    end

    get '/' do
      send_file File.join(settings.public_folder, 'index.html')
    end

    get '/accounts' do
      @account_renderer.render_list(Account.all)
    end

    get '/accounts/:id' do |id|
      account = Account.get(id.to_i) or halt 404
      @account_renderer.render(account)
    end

    put '/accounts/:id' do |id|
      account = Account.first_or_new(id: id.to_i)
      status 201 if account.new?
      account.name = params[:name]

      if account.save
        @account_renderer.render(account)
      else
        status 406
        # TODO errors?
      end
    end

    post '/accounts' do
      account = Account.create(params)
      if account.saved?
        status 201
        @account_renderer.render(account)
      else
        status 406
        # TODO errors?
      end
    end

    delete '/accounts/:id' do |id|
      account = Account.get(id.to_i) or halt 404

      if account.transactions.destroy && account.destroy
        @account_renderer.render(account)
      else
        status 406
        # TODO errors?
      end
    end

    get '/accounts/:id/transactions' do |id|
      account = Account.get(id.to_i) or halt 404
      transactions = account.transactions
      @transaction_renderer.render_list(transactions)
    end
  end

end
