require 'spec_helper'

require './app/models'
require './app/repositories'

module Scrooge
  module Repositories

    shared_examples 'a repository' do
      let(:account) { @accounts.first }

      describe '#get' do
        context 'when the object exists' do
          it 'gets an object from the database' do
            expect(subject.get(account.id)).to eq(account)
          end
        end

        context 'when the object doesn\'t exist' do
          it 'returns nil' do
            expect(subject.get(123)).to be_nil
          end
        end
      end

      describe '#all' do
        it 'returns all objects in the collection' do
          expect(subject.all).to eq(@accounts)
        end
      end

      describe '#create' do
        context 'when params are valid' do
          it 'creates a new object and returns it' do
            name = 'an account'
            object = subject.create(name: name)
            expect(object.name).to eq(name)
            expect(subject.get(object.id)).to eq(object)
          end
        end

        context 'when params are invalid' do
          it 'returns nil and doesn\'t create a record' do
            object = subject.create(name: '')
            expect(object).to be_nil
            expect(subject.all.count).to eq(3)
          end
        end
      end

      describe '#update' do
        context 'when params are valid' do
          it 'returns true and updates the object' do
            new_name = 'a new name'
            account.name = new_name
            updated = subject.update(account)
            expect(updated).to be_true
            expect(subject.get(account.id)).to eq(account)
          end
        end

        context 'when params are invalid' do
          it 'returns false and doesn\'t update the object' do
            account.name = ''
            updated = subject.update(account)
            expect(updated).to be_false
            expect(subject.get(account.id).name).not_to be_empty
          end
        end
      end

      describe '#destroy' do
        it 'destroys the object' do
          destroyed = subject.destroy(account)
          expect(destroyed).to be_true
          expect(subject.get(account.id)).to be_nil
          expect(subject.all.count).to eq(2)
        end
      end
    end

    describe SequelRepository do
      before(:each) do
        Models::Account.dataset.destroy
        @accounts = (1..3).map { |i| Models::Account.create(name: "account #{i}") }
      end

      subject { SequelRepository.new(Models::Account) }
      it_behaves_like 'a repository'
    end

    describe SequelTransactionsRepository do
      describe '#from_account' do
        it 'returns all transactions from an account' do
          Models::Account.dataset.destroy
          Models::Transaction.dataset.destroy

          account = Models::Account.create(name: 'an account')
          (1..3).map do |i|
            transaction = Models::Transaction.create(description: "transaction #{i}", amount: BigDecimal.new('12.34'))
            account.add_transaction(transaction)
          end
          2.times { Models::Transaction.create(description: 'a transaction', amount: BigDecimal.new('0')) }

          expect(subject.from_account(account.id).count).to eq(3)
          expect(subject.from_account(account.id).first).to eq(account.transactions.first)
        end
      end
    end

  end
end
