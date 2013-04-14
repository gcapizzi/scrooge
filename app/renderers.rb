require 'rabl'

module Scrooge

  class AccountJsonRenderer
    def initialize(view_path)
      @view_path = view_path
    end

    def render_object(account)
      render(account, 'account')
    end

    def render_collection(accounts)
      render(accounts, 'accounts')
    end

    private

    def render(object, template)
      Rabl.render(object, template, view_path: @view_path)
    end
  end

  class TransactionJsonRenderer
    def initialize(view_path)
      @view_path = view_path
    end

    def render_object(transaction)
      render(transaction, 'transaction')
    end

    def render_collection(transactions)
      render(transactions, 'transactions')
    end

    private

    def render(object, template)
      Rabl.render(object, template, view_path: @view_path)
    end
  end
end
