require 'spec_helper'
require_relative '../../lib/model'

DataMapper.setup(:default, 'sqlite::memory')

module Scrooge

  describe Account do
    it "doesn't allow an empty name" do
      account = Account.new('')
      expect(account).not_to be_valid
    end

    it 'has many transactions' do
      expect(Account.new('')).to respond_to(:transactions)
    end
  end

  describe Transaction do
    it 'belongs to an account' do
      expect(Transaction.new('', 0)).to respond_to(:account)
    end
  end

end
