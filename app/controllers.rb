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
  end

end
