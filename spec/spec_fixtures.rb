require 'dm-sweatshop'

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
    amount: 12.34
  }}

end
