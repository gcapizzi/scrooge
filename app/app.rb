require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'sinatra/reloader'

require './app/models'
require './app/controllers'
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
      @account_renderer = AccountJsonRenderer.new('app/views')
      @transaction_renderer = TransactionJsonRenderer.new('app/views')
      @account_controller = Controller.new(Account, @account_renderer)
    end

    get('/') { send_file File.join(settings.public_folder, 'index.html') }

    get('/accounts') { @account_controller.index }
    get('/accounts/:id') { |id| @account_controller.show(id.to_i) }
    patch('/accounts/:id') { |id| @account_controller.update(id.to_i, params) }
    post('/accounts') { @account_controller.create(params) }

    delete '/accounts/:id' do |id|
      account = Account.get(id.to_i) or halt 404

      if account.destroy!
        @account_renderer.render_object(account)
      else
        status 406
        # TODO errors?
      end
    end

    get '/accounts/:id/transactions' do |id|
      account = Account.get(id.to_i) or halt 404
      transactions = account.transactions
      @transaction_renderer.render_collection(transactions)
    end
  end

end
