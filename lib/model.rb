require 'data_mapper'

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
end
