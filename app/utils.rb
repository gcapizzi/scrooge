require 'rack'

module Scrooge

  class Request < Rack::Request
    def url_params
      env['rack.routing_args']
    end
  end

  class Action
    def req(env)
      Request.new(env)
    end

    def response(status, body) [status, {}, Array(body)] end

    def ok(body = nil)          response(200, body) end
    def created(body = nil)     response(201, body) end
    def bad_request(body = nil) response(400, body) end
    def not_found(body = nil)   response(404, body) end
  end

end
