module Scrooge

  class Controller
    def initialize(model_class, renderer)
      @model_class = model_class
      @renderer = renderer
    end

    def index
      collection = @model_class.all
      body = @renderer.render_collection(collection)
      [200, [body]]
    end

    def show(id)
      object = @model_class.get(id.to_i)
      return [404, []] if object.nil?
      body = @renderer.render_object(object)
      [200, [body]]
    end
  end

end
