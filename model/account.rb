require 'data_mapper'

module Scrooge

  class Account
    include DataMapper::Resource

    property :id,   Serial
    property :name, String, default: ''
  end

end
