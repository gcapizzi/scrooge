require_relative '../framework'

module Scrooge
  module Actions

    class ListTransactions < Action
      def initialize(accounts_repository, renderer)
        @accounts_repository = accounts_repository
        @renderer = renderer
      end

      def call(req)
        account_id = req.params['account_id'].to_i
        account = @accounts_repository.get(account_id)
        body = @renderer.render(account.transactions)
        ok(body)
      end
    end

  end
end
