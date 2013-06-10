require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'sinatra/reloader'

require './app/models'
require './app/repositories'
require './app/controllers'
require './app/renderers'

module Scrooge

  class App < Sinatra::Base
    set :public_folder, "#{Dir.pwd}/public"

    configure :development do
      register Sinatra::Reloader
    end

    configure :test do
      enable :logging, :dump_errors, :raise_errors
    end

    before do
      @account_renderer = HashAccountsJsonRenderer.new
      @transaction_renderer = HashTransactionsJsonRenderer.new
      @account_repository = SequelRepository.new(Account)
      @account_controller = Controller.new(@account_repository, @account_renderer)
    end

    get('/') { send_file File.join(settings.public_folder, 'index.html') }

    get('/accounts') { @account_controller.index }
    get('/accounts/:account_id') { |account_id| @account_controller.show(account_id.to_i) }
    patch('/accounts/:account_id') { |account_id| @account_controller.update(account_id.to_i, params) }
    post('/accounts') { @account_controller.create(params) }
    delete('/accounts/:account_id') { |account_id| @account_controller.destroy(account_id.to_i) }

    get '/accounts/:id/transactions' do |id|
      account = Account[id.to_i] or halt 404
      transactions = account.transactions
      @transaction_renderer.render(transactions)
    end
  end

end
