require 'spec_helper'

require './app/controllers'

module Scrooge

  describe Controller do
    let(:renderer) { double('renderer') }
    let(:model_collection) { double('model_collection') }
    let(:controller) { Controller.new(model_collection, renderer) }

    describe '#index' do
      it 'returns all objects' do
        json_response = 'Some JSON'

        model_collection.should_receive(:all).and_return(model_collection)
        renderer.should_receive(:render_collection).with(model_collection).and_return(json_response)

        response = controller.index
        expect(response).to eq([200, [json_response]])
      end
    end

    describe '#show' do
      context 'when the object exists' do
        it 'returns the specified object' do
          id = 123
          json_response = 'Some JSON'
          model_object = double('model object')

          model_collection.should_receive(:get).with(id).and_return(model_object)
          renderer.should_receive(:render_object).with(model_object).and_return(json_response)

          response = controller.show(id)
          expect(response).to eq([200, [json_response]])
        end
      end

      context 'when the object doesn\'t exist' do
        it 'returns 404' do
          id = 123
          model_collection.should_receive(:get).with(id).and_return(nil)
          renderer.should_not_receive(:render_object)

          response = controller.show(id)

          expect(response).to eq([404, []])
        end
      end
    end

  end

end
