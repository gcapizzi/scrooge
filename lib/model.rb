require 'data_mapper'

module Scrooge

  class Account
    include DataMapper::Resource

    property :id,   Serial
    property :name, String, required: true

    has n, :transactions

    def initialize(name)
      self.name = name
    end
  end

  class Transaction
    include DataMapper::Resource

    property :id,          Serial
    property :description, String
    property :amount,      Decimal, scale: 2

    belongs_to :account

    def initialize(description, amount)
      self.description = description
      self.amount = amount
    end
  end
end
