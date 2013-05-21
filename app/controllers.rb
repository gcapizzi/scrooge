module Scrooge

  class Controller
    def initialize(repository, renderer)
      @repository = repository
      @renderer = renderer
    end

    def index
      body = @renderer.render_collection(@repository.all)
      ok(body)
    end

    def show(id)
      object = @repository.get(id) or return not_found
      body = @renderer.render_object(object)
      ok(body)
    end

    def update(id, params)
      object = @repository.get(id) or return not_found

      set_attributes!(object, filter_params(params))
      if @repository.update(object)
        body = @renderer.render_object(object)
        ok(body)
      else
        not_acceptable
      end
    end

    def create(params)
      params = filter_params(params)
      object = @repository.create(params)

      if object
        body = @renderer.render_object(object)
        created(body)
      else
        not_acceptable
      end
    end

    def destroy(id)
      object = @repository.get(id) or return not_found

      if @repository.destroy(object)
        body = @renderer.render_object(object)
        ok(body)
      else
        not_acceptable
      end
    end

    private

    def include_key?(list, key)
      list.include?(key.to_s) || list.include?(key.to_sym)
    end

    def filter_params(params, white_list = @repository.attributes)
      params.reject { |key, value| !include_key?(white_list, key) }
    end

    def set_attributes!(object, attributes)
      attributes.each do |attribute, value|
        object.send("#{attribute}=", value)
      end
    end

    def response(status, body)
      [status, Array(body)]
    end

    def ok(body = nil);             response(200, body); end
    def created(body = nil);        response(201, body); end
    def not_found(body = nil);      response(404, body); end
    def not_acceptable(body = nil); response(406, body); end
  end

end
