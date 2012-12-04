require 'spec_helper'
require_relative '../../model/account'

module Scrooge

  describe Account do
    it 'is empty by default' do
      account = Account.new
      expect(account.id).to be_nil
      expect(account.name).to be_empty
    end
  end

end
