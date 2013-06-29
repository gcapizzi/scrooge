module Scrooge
  module Actions

    module ParamsMethods
      private

      def include_key?(list, key)
        list.include?(key.to_s) || list.include?(key.to_sym)
      end

      def filter_params(params, white_list = repository.attributes)
        params.reject { |key| !include_key?(white_list, key) }
      end

      def set_attributes!(object, attributes)
        attributes.each do |attribute, value|
          object.send("#{attribute}=", value)
        end
      end
    end

    module HttpResponsesMethods
      private

      def response(status, body); [status, Array(body)]; end

      def ok(body = nil);          response(200, body); end
      def created(body = nil);     response(201, body); end
      def bad_request(body = nil); response(400, body); end
      def not_found(body = nil);   response(404, body); end
    end

    class Action
      include HttpResponsesMethods

      attr_reader :repository, :renderer

      def initialize(repository, renderer)
        @repository = repository
        @renderer = renderer
      end
    end

    class ListAccounts < Action
      def call
        body = renderer.render(repository.all)
        ok(body)
      end
    end

    class ShowAccount < Action
      def call(params)
        id = params[:account_id].to_i
        account = repository.get(id) or return not_found
        body = renderer.render(account)
        ok(body)
      end
    end

    class UpdateAccount < Action
      include ParamsMethods

      def call(params)
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

    class CreateAccount < Action
      include ParamsMethods

      def call(params)
        params = filter_params(params)
        account = repository.create(params)

        if account
          body = renderer.render(account)
          created(body)
        else
          bad_request
        end
      end
    end

    class DeleteAccount < Action
      def call(params)
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
