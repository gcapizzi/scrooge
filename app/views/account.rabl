object @account => :account
attributes :id, :name
node(:transaction_ids) { |account| account.transactions.map { |t| t.id } }
