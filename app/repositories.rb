module Scrooge

  class DataMapperRepository
    def initialize(model_collection)
      @model_collection = model_collection
    end

    def get(id)
      @model_collection.get(id)
    end

    def all
      @model_collection.all
    end

    def create(params)
      object = @model_collection.create(params)
      if object.saved?
        object
      else
        nil
      end
    end

    def update(object)
      object.save
    end

    def destroy(object)
      object.destroy!
    end

    def attributes
      @model_collection.properties.map(&:name) - [:id]
    end
  end
end
