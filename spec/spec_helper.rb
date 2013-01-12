# Setup SimpleCov

require 'simplecov'
SimpleCov.start

# Setup DataMapper

require 'data_mapper'
DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!

# Helper functions

def parse_json(json_response)
  JSON.parse(json_response.body, symbolize_names: true)
end
