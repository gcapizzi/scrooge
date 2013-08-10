require 'rack'

require_relative '../utils'

module Scrooge
  module Actions
    class AccountsAction < Action
      def initialize(repository, renderer)
        @repository = repository
        @renderer = renderer
      end
    end

    class ListAccounts < AccountsAction
      def call(req)
        body = @renderer.render(@repository.all)
        ok(body)
      end
    end

    class ShowAccount < AccountsAction
      def call(req)
        id = req.url_params['account_id'].to_i
        account = @repository.get(id) or return not_found
        body = @renderer.render(account)
        ok(body)
      end
    end

    class UpdateAccount < AccountsAction
      def call(req)
        id = req.url_params['account_id'].to_i
        account = @repository.get(id) or return not_found

        account.set(req.params)
        if @repository.update(account)
          body = @renderer.render(account)
          ok(body)
        else
          bad_request
        end
      end
    end

    class CreateAccount < AccountsAction
      def call(req)
        account = @repository.create(req.params)

        if account
          body = @renderer.render(account)
          created(body)
        else
          bad_request
        end
      end
    end

    class DeleteAccount < AccountsAction
      def call(req)
        id = req.url_params['account_id'].to_i
        account = @repository.get(id) or return not_found

        if @repository.destroy(account)
          body = @renderer.render(account)
          ok(body)
        else
          bad_request
        end
      end
    end

  end
end
