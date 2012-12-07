require 'data_mapper'

module Scrooge

  class Account
    include DataMapper::Resource

    property :id,   Serial
    property :name, String, required: true

    def initialize(name)
      self.name = name
    end
  end

end
