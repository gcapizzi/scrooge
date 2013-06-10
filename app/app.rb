require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'sinatra/reloader'

require './app/models'
require './app/repositories'
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
      @account_repository = SequelRepository.new(Account)
    end

    get('/') { send_file File.join(settings.public_folder, 'index.html') }

    get('/accounts') { Actions::ListAccounts.new(@account_repository, @account_renderer).call }
    get('/accounts/:account_id') { |account_id| Actions::ShowAccount.new(@account_repository, @account_renderer).call(account_id) }
    patch('/accounts/:account_id') { |account_id| Actions::UpdateAccount.new(@account_repository, @account_renderer).call(account_id, params) }
    post('/accounts') { Actions::CreateAccount.new(@account_repository, @account_renderer).call(params) }
    delete('/accounts/:account_id') { |account_id| Actions::DeleteAccount.new(@account_repository, @account_renderer).call(account_id) }
  end

end
