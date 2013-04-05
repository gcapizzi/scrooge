require 'rubygems'
require 'bundler/setup'

require 'dm-sweatshop'

require './app/models'

module Scrooge

  Account.fix(:invalid) {{
    name: ''
  }}

  Account.fix(:valid) {{
    name: /\w+/.gen,
    transactions: 3.of { Transaction.make }
  }}

  Transaction.fix {{
    description: /\w+/.gen,
    amount: BigDecimal.new("12.34")
  }}

end
