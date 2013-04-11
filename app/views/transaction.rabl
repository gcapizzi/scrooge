object @transaction => :transaction
attributes :id, :description, :account_id
node(:amount) { |transaction| transaction.amount.to_s('F') }
