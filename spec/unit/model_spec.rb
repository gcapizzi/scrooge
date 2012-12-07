require 'spec_helper'
require_relative '../../model/account'

module Scrooge

  describe Account do
    it "doesn't allow an empty name" do
      account = Account.new('')
      expect(account).not_to be_valid
    end
  end

end
