module Scrooge
  module Repositories

    class SequelRepository
      def initialize(model_collection)
        @model_collection = model_collection
      end

      def get(id)
        @model_collection[id]
      end

      def all
        @model_collection.all
      end

      def create(params)
        @model_collection.create(params)
      end

      def update(object)
        object.save
      end

      def destroy(object)
        object.destroy
      end
    end

  end
end
