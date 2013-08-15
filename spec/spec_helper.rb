require 'rubygems'
require 'bundler/setup'

ENV['RACK_ENV'] = 'test'

# Setup SimpleCov

require 'simplecov'
SimpleCov.start if ENV['COVERAGE']

# Fabrication

require 'fabrication'

# Database Cleaner

require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

# Helper functions

require 'json'

def parse_json(json_response)
  JSON.parse(json_response, symbolize_names: true)
end

def make_request(params = {})
  req = double(Scrooge::Request, params: params)
  resp = subject.call(req)
  Rack::MockResponse.new(*resp)
end
