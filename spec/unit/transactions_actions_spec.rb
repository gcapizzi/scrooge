require './app/actions/transactions_actions'

describe Scrooge::Actions do
  let(:account_id) { '123' }
  let(:transactions_repository) { double('transactions repository', attributes: [:description, :amount]) }
  let(:transactions) { double('transactions') }
  let(:transactions_renderer) { 'transactions renderer' }
  let(:transactions_json) { 'transactions json' }

  before do
    transactions_repository.stub(:from_account).with(account_id.to_i).and_return(transactions)
  end

  subject { Scrooge::Actions::ListTransactions.new(transactions_repository, transactions_renderer) }

  it 'lists all transactions from an account' do
    transactions_renderer.should_receive(:render).with(transactions).and_return(transactions_json)

    response = make_request('account_id' => account_id)
    expect(response.status).to eq(200)
    expect(response.body).to eq(transactions_json)
  end
end
