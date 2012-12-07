require 'spec_helper'
require_relative '../../lib/model'

module Scrooge

  describe Account do
    it "doesn't allow an empty name" do
      account = Account.new('')
      expect(account).not_to be_valid
    end
  end

end
