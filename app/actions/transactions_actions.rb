require 'rack'

require_relative '../utils'

module Scrooge
  module Actions
    module Transactions

      class List < Action
        attr_reader :accounts_repository, :renderer

        def initialize(accounts_repository, renderer)
          @accounts_repository = accounts_repository
          @renderer = renderer
        end

        def call(env)
          account_id = req(env).url_params[:account_id].to_i
          account = accounts_repository.get(account_id)
          body = renderer.render(account.transactions)
          ok(body)
        end
      end

    end
  end
end
