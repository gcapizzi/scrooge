require 'rack'

module Scrooge

  class Request < Rack::Request
    def params
      super.merge(env['rack.routing_args'])
    end
  end

  class Action
    def req(env)
      Request.new(env)
    end

    def set_attributes!(object, attributes)
      attributes.each do |attribute, value|
        object.send("#{attribute}=", value)
      end
    end

    def include_key?(list, key)
      list.include?(key.to_s) || list.include?(key.to_sym)
    end

    def filter_params(params, white_list = repository.attributes)
      params.reject { |key| !include_key?(white_list, key) }
    end

    def response(status, body) [status, {}, Array(body)] end

    def ok(body = nil)          response(200, body) end
    def created(body = nil)     response(201, body) end
    def bad_request(body = nil) response(400, body) end
    def not_found(body = nil)   response(404, body) end
  end

end
