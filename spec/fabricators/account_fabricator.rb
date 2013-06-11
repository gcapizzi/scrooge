require 'fabrication'

Fabricator(:account, class_name: 'scrooge/models/account') do
  name { sequence(:name) { |i| "account #{i}" } }
  transactions(count: 3) { |_, i| Fabricate(:transaction) }
end
