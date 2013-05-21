require 'rubygems'
require 'bundler/setup'

require 'data_mapper'
require 'sequel'

case ENV['RACK_ENV']
when 'test'
  DB = Sequel.sqlite
  DataMapper.setup(:default, 'sqlite::memory:')
when 'development'
  DB = Sequel.sqlite('db/scrooge.db')
  DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/scrooge.db")
end

module Scrooge

  class Account
    include DataMapper::Resource

    property :id,   Serial
    property :name, String, required: true

    has n, :transactions
  end

  class Transaction
    include DataMapper::Resource

    property :id,          Serial
    property :description, String
    property :amount,      Decimal, scale: 2

    belongs_to :account
  end

  DataMapper.finalize

  class SequelAccount < Sequel::Model
    set_dataset :accounts

    self.raise_on_save_failure = false

    def validate
      super
      errors.add(:name, "can't be empty") if name.empty?
    end
  end
end
