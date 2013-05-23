collection @transactions, root: 'transactions', object_root: false
attributes :id, :description, :account_id
node(:amount) { |transaction| transaction.amount.to_s('F') }
