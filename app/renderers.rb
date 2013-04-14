require 'rabl'

module Scrooge

  class JsonRenderer
    def initialize(view_path)
      @view_path = view_path
    end

    private

    def render(object, template)
      Rabl.render(object, template, view_path: @view_path)
    end
  end

  class AccountJsonRenderer < JsonRenderer
    def render_object(account)
      render(account, 'account')
    end

    def render_collection(accounts)
      render(accounts, 'accounts')
    end
  end

  class TransactionJsonRenderer < JsonRenderer
    def render_object(transaction)
      render(transaction, 'transaction')
    end

    def render_collection(transactions)
      render(transactions, 'transactions')
    end
  end
end
