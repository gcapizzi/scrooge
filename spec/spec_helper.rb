require 'rubygems'
require 'bundler/setup'

ENV['RACK_ENV'] = 'test'

# Setup SimpleCov

require 'simplecov'
SimpleCov.start

# Helper functions

def parse_json(json_response)
  Oj.load(json_response.body, symbol_keys: true)
end
