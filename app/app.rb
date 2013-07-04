require 'rubygems'
require 'bundler/setup'

require 'rack/mount'

require './app/models'
require './app/actions'
require './app/repositories'
require './app/renderers'

module Scrooge
  accounts_renderer   = Renderers::HashAccountsJsonRenderer.new
  accounts_repository = Repositories::SequelRepository.new(Models::Account)

  list_accounts  = Actions::ListAccounts.new(accounts_repository, accounts_renderer)
  show_account   = Actions::ShowAccount.new(accounts_repository, accounts_renderer)
  update_account = Actions::UpdateAccount.new(accounts_repository, accounts_renderer)
  create_account = Actions::CreateAccount.new(accounts_repository, accounts_renderer)
  delete_account = Actions::DeleteAccount.new(accounts_repository, accounts_renderer)

  App = Rack::Mount::RouteSet.new do |app|
    app.add_route list_accounts,  { request_method: 'GET',    path_info: %r{^/accounts$}                    }, {}, :list_accounts
    app.add_route show_account,   { request_method: 'GET',    path_info: %r{^/accounts/(?<account_id>\d+)$} }, {}, :show_account
    app.add_route update_account, { request_method: 'PATCH',  path_info: %r{^/accounts/(?<account_id>\d+)$} }, {}, :update_account
    app.add_route create_account, { request_method: 'POST',   path_info: %r{^/accounts$}                    }, {}, :create_account
    app.add_route delete_account, { request_method: 'DELETE', path_info: %r{^/accounts/(?<account_id>\d+)$} }, {}, :delete_account
  end
end
