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

      def get_object(id)
        @repository.get(id)
      end
    end

    class ListAction < Action
      def call(req)
        ok(render(get_objects(req.params)))
      end

      def get_objects(params = {})
        @repository.all
      end
    end

    class ShowAction < Action
      def call(req)
        id = req.params['id'].to_i
        object = get_object(id) or return not_found
        body = render(object)
        ok(body)
      end
    end

    class UpdateAction < Action
      def call(req)
        id = req.params['id'].to_i
        object = get_object(id) or return not_found

        object.set(req.params)
        if update_object(object)
          body = render(object)
          ok(body)
        else
          bad_request
        end
      end

      def update_object(object)
        @repository.update(object)
      end
    end

    class CreateAction < Action
      def call(req)
        object = create_object(req.params)

        if object
          body = render(object)
          created(body)
        else
          bad_request
        end
      end

      def create_object(params)
        @repository.create(params)
      end
    end

    class DeleteAction < Action
      def call(req)
        id = req.params['id'].to_i
        object = get_object(id) or return not_found

        if destroy_object(object)
          body = render(object)
          ok(body)
        else
          bad_request
        end
      end

      def destroy_object(object)
        @repository.destroy(object)
      end
    end
  end
end
