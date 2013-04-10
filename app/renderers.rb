require 'rubygems'
require 'bundler/setup'

require 'json'
require 'data_mapper'

module Scrooge

  class AccountJsonRenderer
    def render(account)
      as_json(account).to_json
    end

    def render_list(accounts)
      { accounts: accounts.map { |a| as_json(a) } }.to_json
    end

    private

    def as_json(account)
      attributes = account.attributes

      unless account.transactions.empty?
        transaction_ids = account.transactions.map { |t| t.id }
        attributes[:transaction_ids] = transaction_ids
      end

      { account: attributes }
    end
  end

  class TransactionJsonRenderer
    def render(transaction)
      as_json(transaction).to_json
    end

    def render_list(transactions)
      { transactions: transactions.map { |t| as_json(t) } }.to_json
    end

    private

    def as_json(transaction)
      attributes = transaction.attributes
      attributes[:amount] = transaction.amount.to_s('F')
      { transaction: attributes }
    end
  end
end
