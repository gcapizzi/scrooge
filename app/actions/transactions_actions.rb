require './lib/framework'

module Scrooge
  module Actions

    class ListTransactions < ListAction
      def get_objects(params)
        account_id = params['account_id'].to_i
        @repository.from_account(account_id)
      end
    end

  end
end
