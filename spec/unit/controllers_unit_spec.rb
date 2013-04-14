require 'spec_helper'

require './app/controllers'

module Scrooge

  describe Controller do
    let(:renderer) { double('renderer') }
    let(:model_class) { double('model_class') }
    let(:controller) { Controller.new(model_class, renderer) }

    describe '#index' do
      it 'returns all objects' do
        model_collection = double('model collection')
        json_response = 'Some JSON'

        model_class.should_receive(:all).and_return(model_collection)
        renderer.should_receive(:render_collection).with(model_collection).and_return(json_response)

        response = controller.index
        expect(response[0]).to eq(200)
        expect(response[1]).to eq([json_response])
      end
    end

    describe '#show' do
      context 'when the object exists' do
        it 'returns the specified object' do
          id = 123
          json_response = 'Some JSON'
          model_object = double('model object')

          model_class.should_receive(:get).with(id).and_return(model_object)
          renderer.should_receive(:render_object).with(model_object).and_return(json_response)

          response = controller.show(id)
          expect(response[0]).to eq(200)
          expect(response[1]).to eq([json_response])
        end
      end

      context 'when the object doesn\'t exist' do
        it 'returns 404' do
          id = 123

          model_class.should_receive(:get).with(id).and_return(nil)
          renderer.should_not_receive(:render_object)

          response = controller.show(id)

          expect(response[0]).to eq(404)
          expect(response[1]).to be_empty
        end
      end
    end

  end

end
