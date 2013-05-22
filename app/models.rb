require 'rubygems'
require 'bundler/setup'

require 'sequel'

case ENV['RACK_ENV']
when 'test'
  DB = Sequel.sqlite
  Sequel.extension :migration
  Sequel::Migrator.run(DB, 'db/migrations')
when 'development'
  DB = Sequel.sqlite('db/scrooge.db')
end

module Scrooge

  class Account < Sequel::Model
    set_dataset :accounts

    one_to_many :transactions

    self.raise_on_save_failure = false

    def validate
      super
      errors.add(:name, "can't be empty") if name.empty?
    end
  end

  class Transaction < Sequel::Model
    set_dataset :transactions

    many_to_one :account

    self.raise_on_save_failure = false
  end

end
