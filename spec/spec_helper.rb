require 'simplecov'
SimpleCov.start

def parse_json(json_response)
  JSON.parse(json_response.body, symbolize_names: true)
end
