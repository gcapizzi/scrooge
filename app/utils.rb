require 'rack'

module Scrooge

  class Request < Rack::Request
    def self.from_env(env)
      new(env)
    end

    def url_params
      stringify_keys(env['rack.routing_args'])
    end

    private

    def stringify_keys(hash)
      Hash[hash.to_a.map { |key, val| [key.to_s, val] }]
    end
  end

  class Action
    def response(status, body) [status, {}, Array(body)] end

    def ok(body = nil)          response(200, body) end
    def created(body = nil)     response(201, body) end
    def bad_request(body = nil) response(400, body) end
    def not_found(body = nil)   response(404, body) end
  end

end
