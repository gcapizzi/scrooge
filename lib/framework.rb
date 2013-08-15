require 'rack'
require 'rack/mount'

module Scrooge

  class Request < Rack::Request
    def self.from_env(env)
      new(env)
    end

    def url_params
      stringify_keys(env['rack.routing_args'])
    end

    def params
      url_params.merge(super)
    end

    private

    def stringify_keys(hash)
      Hash[hash.to_a.map { |key, val| [key.to_s, val] }]
    end
  end

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

  class Router
    def initialize(route_set = Rack::Mount::RouteSet.new)
      @route_set = route_set
    end

    def route(verb, url_pattern, action, name)
      wrapped_action = wrap_action(action)
      matcher = { request_method: verb, path_info: url_pattern }
      @route_set.add_route(wrapped_action, matcher, {}, name)
    end

    # verb-specific routes
    def get    url_pattern, action, name; route 'GET',    url_pattern, action, name; end
    def post   url_pattern, action, name; route 'POST',   url_pattern, action, name; end
    def patch  url_pattern, action, name; route 'PATCH',  url_pattern, action, name; end
    def delete url_pattern, action, name; route 'DELETE', url_pattern, action, name; end

    def finalize
      @route_set.freeze
    end

    def build(&block)
      instance_eval(&block) and finalize if block_given?
    end

    def self.build(&block)
      new.build(&block)
    end

    def call(env)
      @route_set.call(env)
    end

    private

    def wrap_action(action)
      proc do |env|
        request = Scrooge::Request.from_env(env)
        action.call(request)
      end
    end
  end
end
