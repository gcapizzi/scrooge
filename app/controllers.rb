module Scrooge

  class Controller
    def initialize(model_collection, renderer)
      @model_collection = model_collection
      @renderer = renderer
    end

    def index
      body = @renderer.render_collection(@model_collection)
      ok(body)
    end

    def show(id)
      object = @model_collection.get(id)
      return not_found if object.nil?

      body = @renderer.render_object(object)
      ok(body)
    end

    def update(id, params)
      object = @model_collection.get(id)

      return not_found if object.nil?

      params = filter_params(params, [:name])
      if object.update(params)
        body = @renderer.render_object(object)
        ok(body)
      else
        not_acceptable
      end
    end

    def create(params)
      params = filter_params(params, [:name])
      object = @model_collection.create(params)

      if object.saved?
        body = @renderer.render_object(object)
        created(body)
      else
        not_acceptable
      end
    end

    def destroy(id)
      object = @model_collection.get(id)
      return not_found if object.nil?

      if object.destroy!
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

    def filter_params(params, white_list)
      params.reject { |key, value| !include_key?(white_list, key) }
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
