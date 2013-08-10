require 'rubygems'
require 'bundler/setup'

ENV['RACK_ENV'] = 'test'

# Setup SimpleCov

require 'simplecov'
SimpleCov.start if ENV['COVERAGE']

# Fabrication

require 'fabrication'

# Helper functions

require 'json'

def parse_json(json_response)
  JSON.parse(json_response, symbolize_names: true)
end

def make_request(url_params = {}, params = {})
  Rack::MockRequest.new(subject).get('', params: params, 'rack.routing_args' => url_params, lint: true)
end
