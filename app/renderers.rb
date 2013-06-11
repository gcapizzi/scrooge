module Scrooge
  module Renderers

    class HashAccountsJsonRenderer
      def render(account_object_or_collection)
        account_collection = Array(account_object_or_collection)

        {
          accounts: account_collection.map do |account|
          {
            id: account.id,
            name: account.name,
            links: {
            transactions: account.transactions.map(&:id)
          }
          }
          end
        }.to_json
      end
    end

    class HashTransactionsJsonRenderer
      def render(transaction_object_or_collection)
        transacion_collection = Array(transaction_object_or_collection)

        {
          transactions: transacion_collection.map do |transaction|
          {
            id: transaction.id,
            description: transaction.description,
            amount: transaction.amount.to_s('F'),
            links: {
            account: transaction.account.id
          }
          }
          end
        }.to_json
      end
    end

  end
end
