require 'rack'

require_relative '../utils'

module Scrooge
  module Actions
    module Accounts

      class Action < Action
        attr_reader :repository, :renderer

        def initialize(repository, renderer)
          @repository = repository
          @renderer = renderer
        end
      end

      class List < Action
        def call(env)
          body = renderer.render(repository.all)
          ok(body)
        end
      end

      class Show < Action
        def call(env)
          params = req(env).params
          id = params[:account_id].to_i
          account = repository.get(id) or return not_found
          body = renderer.render(account)
          ok(body)
        end
      end

      class Update < Action
        def call(env)
          params = req(env).params

          id = params[:account_id].to_i
          account = repository.get(id) or return not_found

          set_attributes!(account, filter_params(params))
          if repository.update(account)
            body = renderer.render(account)
            ok(body)
          else
            bad_request
          end
        end
      end

      class Create < Action
        def call(env)
          params = req(env).params
          account = repository.create(filter_params(params))

          if account
            body = renderer.render(account)
            created(body)
          else
            bad_request
          end
        end
      end

      class Delete < Action
        def call(env)
          params = req(env).params
          id = params[:account_id].to_i
          account = repository.get(id) or return not_found

          if repository.destroy(account)
            body = renderer.render(account)
            ok(body)
          else
            bad_request
          end
        end
      end

    end
  end
end
