module Scrooge
  module Actions
    class Action
      def initialize(repository, renderer)
        @repository = repository
        @renderer = renderer
      end

      def response(status, body) [status, {}, Array(body)] end

      def ok(body = nil)          response(200, body) end
      def created(body = nil)     response(201, body) end
      def bad_request(body = nil) response(400, body) end
      def not_found(body = nil)   response(404, body) end

      def render(objects)
        @renderer.render(objects)
      end

      def get_repository(params)
        @repository
      end
    end

    class ListAction < Action
      def call(req)
        objects = get_repository(req.params).all
        ok(render(objects))
      end
    end

    class ShowAction < Action
      def call(req)
        id = req.params['id'].to_i
        repository = get_repository(req.params)
        object = repository.get(id) or return not_found
        body = render(object)
        ok(body)
      end
    end

    class UpdateAction < Action
      def call(req)
        id = req.params['id'].to_i
        repository = get_repository(req.params)
        object = repository.get(id) or return not_found

        object.set(req.params)
        if repository.update(object)
          body = render(object)
          ok(body)
        else
          bad_request
        end
      end
    end

    class CreateAction < Action
      def call(req)
        repository = get_repository(req.params)
        object = repository.create(req.params)

        if object
          body = render(object)
          created(body)
        else
          bad_request
        end
      end
    end

    class DeleteAction < Action
      def call(req)
        id = req.params['id'].to_i
        repository = get_repository(req.params)
        object = repository.get(id) or return not_found

        if repository.destroy(object)
          body = render(object)
          ok(body)
        else
          bad_request
        end
      end
    end
  end
end
