require 'rack/mount'

class Router
  def initialize(route_set = Rack::Mount::RouteSet.new)
    @route_set = route_set
  end

  def route(verb, url_pattern, action, name)
    @route_set.add_route(action, { request_method: verb, path_info: url_pattern }, {}, name)
  end

  # verb-specific routes
  def get    url_pattern, action, name; route 'GET',    url_pattern, action, name; end
  def post   url_pattern, action, name; route 'POST',   url_pattern, action, name; end
  def patch  url_pattern, action, name; route 'PATCH',  url_pattern, action, name; end
  def delete url_pattern, action, name; route 'DELETE', url_pattern, action, name; end

  def finalize
    @route_set.freeze
  end

  def build(&block)
    instance_eval(&block) and finalize if block_given?
  end

  def self.build(&block)
    new.build(&block)
  end
end
