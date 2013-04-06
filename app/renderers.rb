require 'rubygems'
require 'bundler/setup'

require 'json'
require 'data_mapper'

module Scrooge

  class AccountJsonRenderer
    def render(account)
      as_json(account).to_json
    end

    def render_list(account_list)
      { accounts: account_list.map { |a| as_json(a) } }.to_json
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

end
