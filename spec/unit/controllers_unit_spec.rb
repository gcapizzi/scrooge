require 'spec_helper'

require './app/controllers'

module Scrooge

  describe Controller do
    let(:json_response) { 'some json' }
    let(:renderer) { double('renderer', render_object: json_response, render_collection: json_response) }
    let(:model_object) { double('model object', saved?: true) }
    let(:invalid_model_object) { double('invalid model object', saved?: false) }
    let(:model_collection) { double('model collection', get: model_object) }
    let(:empty_model_collection) { double('empty model collection', get: nil) }
    let(:controller) { Controller.new(model_collection, renderer) }
    let(:empty_controller) { Controller.new(empty_model_collection, renderer) }

    describe '#index' do
      it 'returns all objects' do
        expect(controller.index).to eq([200, [json_response]])
      end
    end

    describe '#show' do
      context 'when the object exists' do
        it 'returns the specified object' do
          expect(controller.show(123)).to eq([200, [json_response]])
        end
      end

      context 'when the object doesn\'t exist' do
        it 'returns a 404 Not Found' do
          expect(empty_controller.show(123)).to eq([404, []])
        end
      end
    end

    describe '#update' do
      context 'when the account exists' do
        context 'when params are valid' do
          it 'updates the account' do
            new_name = 'new account name'
            model_object.should_receive(:update).with(name: new_name).and_return(true)
            response = controller.update(123, name: new_name)
            expect(response).to eq([200, [json_response]])
          end
        end

        context 'when params are invalid' do
          it 'returns a 406 Not Acceptable and doesn\'t update the account' do
            name = 'an invalid name'
            model_object.should_receive(:update).with(name: name).and_return(false)
            response = controller.update(123, name: name)
            expect(response).to eq([406, []])
          end
        end
      end

      context 'when the account doesn\'t exist' do
        it 'returns a 404 Not Found' do
          expect(empty_controller.update(123, name: 'anything')).to eq([404, []])
        end
      end
    end

    describe '#create' do
      context 'when params are valid' do
        it 'creates a new object' do
          name = 'a name'
          model_collection.should_receive(:create).with(name: name).and_return(model_object)
          response = controller.create(name: name)
          expect(response).to eq([201, [json_response]])
        end
      end

      context 'when params are invalid' do
        it 'returns a 406 Not Acceptable and doesn\'t create an account' do
          name = 'an invalid name'
          model_collection.should_receive(:create).with(name: name).and_return(invalid_model_object)
          response = controller.create(name: name)
          expect(response).to eq([406, []])
        end
      end
    end

    describe '#destroy' do
      context 'when the objects exists' do
        context 'when the operation succeeds' do
          it 'destroys the object' do
            model_object.should_receive(:destroy!).and_return(true)
            response = controller.destroy(123)
            expect(response).to eq([200, [json_response]])
          end
        end

        context 'when the operation fails' do
          it 'returns a 406 Not Acceptable and doesn\'t destroy the object' do
            model_object.should_receive(:destroy!).and_return(false)
            response = controller.destroy(123)
            expect(response).to eq([406, []])
          end
        end
      end

      context 'when the object doesn\'t exist' do
        it 'returns a 404 Not Found' do
          response = empty_controller.destroy(123)
          expect(response).to eq([404, []])
        end
      end
    end
  end

end
