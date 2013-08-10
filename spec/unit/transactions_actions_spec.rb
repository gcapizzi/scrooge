require './app/actions/transactions_actions'

describe Scrooge::Actions do
  let(:account_id) { '123' }
  let(:account) { double('account', id: account_id) }
  let(:accounts_repository) { double('accounts repository', attributes: [:name]) }
  let(:transactions) { double('transactions') }
  let(:transactions_renderer) { 'transactions renderer' }
  let(:transactions_json) { 'transactions json' }

  before do
    accounts_repository.stub(:get).with(account_id.to_i).and_return(account)
    account.stub(:transactions).and_return(transactions)
  end

  subject { Scrooge::Actions::ListTransactions.new(accounts_repository, transactions_renderer) }

  it 'lists all transactions from an account' do
    transactions_renderer.should_receive(:render).with(transactions).and_return(transactions_json)

    response = make_request(account_id: account_id)
    expect(response.status).to eq(200)
    expect(response.body).to eq(transactions_json)
  end
end
