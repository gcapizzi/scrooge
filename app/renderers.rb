require 'rabl'

Rabl.configure do |config|
  config.include_json_root = false
  config.include_child_root = false
end

module Scrooge

  class JsonRenderer
    def initialize(template, view_path)
      @template = template
      @view_path = view_path
    end

    def render(object_or_collection)
      Rabl.render(Array(object_or_collection), @template, view_path: @view_path)
    end
  end

end
