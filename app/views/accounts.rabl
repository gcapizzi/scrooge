collection @accounts, root: 'accounts', object_root: false
attributes :id, :name
node(:transaction_ids) { |account| account.transactions.map { |t| t.id } }
