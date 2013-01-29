# Require all test gems

require 'bundler'
Bundler.require(:test)

# Setup SimpleCov

SimpleCov.start

# Helper functions

def parse_json(json_response)
  JSON.parse(json_response.body, symbolize_names: true)
end
