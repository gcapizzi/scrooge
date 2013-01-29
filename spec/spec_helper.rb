require 'rubygems'
require 'bundler/setup'

# Setup SimpleCov

require 'simplecov'
SimpleCov.start

# Helper functions

def parse_json(json_response)
  JSON.parse(json_response.body, symbolize_names: true)
end
