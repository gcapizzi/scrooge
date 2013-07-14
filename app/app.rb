require 'rubygems'
require 'bundler/setup'

require './app/models'
require './app/actions/accounts_actions'
require './app/actions/transactions_actions'
require './app/repositories'
require './app/renderers'
require './app/router'

module Scrooge
  accounts_renderer   = Renderers::HashAccountsJsonRenderer.new
  accounts_repository = Repositories::SequelRepository.new(Models::Account)

  list_accounts  = Actions::Accounts::List.new(accounts_repository, accounts_renderer)
  show_account   = Actions::Accounts::Show.new(accounts_repository, accounts_renderer)
  update_account = Actions::Accounts::Update.new(accounts_repository, accounts_renderer)
  create_account = Actions::Accounts::Create.new(accounts_repository, accounts_renderer)
  delete_account = Actions::Accounts::Delete.new(accounts_repository, accounts_renderer)

  transactions_renderer = Renderers::HashTransactionsJsonRenderer.new

  list_transactions = Actions::Transactions::List.new(accounts_repository, transactions_renderer)

  App = Router.build do
    get    %r{^/accounts$},                    list_accounts,  :list_accounts
    get    %r{^/accounts/(?<account_id>\d+)$}, show_account,   :show_account
    patch  %r{^/accounts/(?<account_id>\d+)$}, update_account, :update_account
    post   %r{^/accounts$},                    create_account, :create_account
    delete %r{^/accounts/(?<account_id>\d+)$}, delete_account, :delete_account

    get %r{^/accounts/(?<account_id>\d+)/transactions$}, list_transactions, :list_transactions
  end
end
