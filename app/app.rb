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

    helpers do
      def accounts_renderer; HashAccountsJsonRenderer.new; end
      def accounts_repository; SequelRepository.new(Models::Account); end

      def list_accounts; Actions::ListAccounts.new(accounts_repository, accounts_renderer); end
      def show_account; Actions::ShowAccount.new(accounts_repository, accounts_renderer); end
      def update_account; Actions::UpdateAccount.new(accounts_repository, accounts_renderer); end
      def create_account; Actions::CreateAccount.new(accounts_repository, accounts_renderer); end
      def delete_account; Actions::DeleteAccount.new(accounts_repository, accounts_renderer); end
    end

    get('/') { send_file File.join(settings.public_folder, 'index.html') }

    get('/accounts') { list_accounts.call }
    get('/accounts/:account_id') { |account_id| show_account.call(account_id) }
    patch('/accounts/:account_id') { |account_id| update_account.call(account_id, params) }
    post('/accounts') { create_account.call(params) }
    delete('/accounts/:account_id') { |account_id| delete_account.call(account_id) }
  end

end
