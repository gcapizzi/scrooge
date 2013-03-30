require 'rubygems'
require 'bundler/setup'

# Setup SimpleCov

require 'simplecov'
SimpleCov.start

# Helper functions

def parse_json(json_response)
  Oj.load(json_response.body, symbol_keys: true)
end
