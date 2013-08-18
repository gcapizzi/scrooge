require './lib/framework'

module Scrooge
  module Actions

    module TransactionsAction
      def get_repository(params)
        account_id = params['account_id'].to_i
        @repository.filter(account_id: account_id)
      end
    end

    class ListTransactions < ListAction
      include TransactionsAction
    end
  end
end
