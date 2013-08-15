require 'rack'

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
end
