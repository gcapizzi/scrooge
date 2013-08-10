require 'rubygems'
require 'bundler/setup'

require './app/models'
require './app/actions/accounts_actions'
require './app/actions/transactions_actions'
require './app/repositories'
require './app/renderers'
require './app/router'
require './app/container'

module Scrooge
  router = Router.new
  Container.register(:router) { router }

  router.build do
    get    %r{^/accounts$},            Container.list_accounts,  :list_accounts
    get    %r{^/accounts/(?<id>\d+)$}, Container.show_account,   :show_account
    patch  %r{^/accounts/(?<id>\d+)$}, Container.update_account, :update_account
    post   %r{^/accounts$},            Container.create_account, :create_account
    delete %r{^/accounts/(?<id>\d+)$}, Container.delete_account, :delete_account

    get %r{^/accounts/(?<account_id>\d+)/transactions$}, Container.list_transactions, :list_transactions
  end

  App = router
end
