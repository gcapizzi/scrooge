require 'fabrication'

Fabricator(:transaction, class_name: 'scrooge/transaction') do
  description { sequence(:description) { |i| "transaction #{i}" } }
  amount { BigDecimal.new('12.34') }
end
