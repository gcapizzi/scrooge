module Scrooge
  module Repositories

    class SequelRepository
      def initialize(model_class)
        @model_class = model_class
      end

      def get(id)
        @model_class[id]
      end

      def all
        @model_class.all
      end

      def create(params)
        @model_class.create(params)
      end

      def update(object)
        object.save
      end

      def destroy(object)
        object.destroy
      end

      def filter(constraints)
        SequelRepository.new(@model_class.where(constraints))
      end
    end

  end
end
