module Scrooge

  class Controller
    def initialize(model_collection, renderer)
      @model_collection = model_collection
      @renderer = renderer
    end

    def index
      collection = @model_collection.all
      body = @renderer.render_collection(collection)
      [200, [body]]
    end

    def show(id)
      object = @model_collection.get(id)
      return [404, []] if object.nil?
      body = @renderer.render_object(object)
      [200, [body]]
    end

    def update(id, params)
      object = @model_collection.get(id)

      return [404, []] if not object

      params = filter_params(params, [:name])
      if object.update(params)
        body = @renderer.render_object(object)
        [200, [body]]
      else
        [406, []]
      end
    end

    def create(params)
      params = filter_params(params, [:name])
      object = @model_collection.create(params)

      if object.saved?
        body = @renderer.render_object(object)
        [201, [body]]
      else
        [406, []]
      end
    end

    def destroy(id)
      object = @model_collection.get(id)

      return [404, []] if object.nil?

      if object.destroy!
        body = @renderer.render_object(object)
        [200, body]
      else
        [406, []]
      end
    end

    private

    def include_key?(list, key)
      list.include?(key.to_s) || list.include?(key.to_sym)
    end

    def filter_params(params, white_list)
      params.reject { |key, value| !include_key?(white_list, key) }
    end
  end

end
