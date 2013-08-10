require 'dim'

require './app/actions/accounts_actions'
require './app/actions/transactions_actions'
require './app/repositories'
require './app/renderers'

module Scrooge
  Container = Dim::Container.new

  Container.register(:accounts_renderer)   { Renderers::HashAccountsJsonRenderer.new }
  Container.register(:accounts_repository) { Repositories::SequelRepository.new(Models::Account) }

  Container.register(:list_accounts)  { |c| Actions::ListAccounts.new(c.accounts_repository, c.accounts_renderer)  }
  Container.register(:show_account)   { |c| Actions::ShowAccount.new(c.accounts_repository, c.accounts_renderer)   }
  Container.register(:update_account) { |c| Actions::UpdateAccount.new(c.accounts_repository, c.accounts_renderer) }
  Container.register(:create_account) { |c| Actions::CreateAccount.new(c.accounts_repository, c.accounts_renderer) }
  Container.register(:delete_account) { |c| Actions::DeleteAccount.new(c.accounts_repository, c.accounts_renderer) }

  Container.register(:transactions_renderer) { Renderers::HashTransactionsJsonRenderer.new }

  Container.register(:list_transactions) { |c| Actions::ListTransactions.new(c.accounts_repository, c.transactions_renderer) }
end
