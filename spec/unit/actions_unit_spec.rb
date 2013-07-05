require './app/actions/accounts_actions'
require './app/actions/transactions_actions'

def req(url_params = {}, params = {})
  Rack::MockRequest.new(subject).get('', params: params, 'rack.routing_args' => url_params, lint: true)
end

describe Scrooge::Actions do
  let(:accounts_repository) { double('accounts repository', attributes: [:name]) }
  let(:account_id) { '123' }
  let(:account) { double('account', id: account_id) }

  before do
    accounts_repository.stub(:get).with(account_id.to_i).and_return(account)
  end

  describe Scrooge::Actions::Accounts do
    let(:accounts_renderer) { double('accounts renderer') }
    let(:accounts) { double('accounts') }
    let(:wrong_account_id) { '456' }
    let(:account_json) { 'account json' }
    let(:accounts_json) { 'accounts json' }

    before do
      accounts_repository.stub(:all).and_return(accounts)
      accounts_repository.stub(:get).with(wrong_account_id.to_i).and_return(nil)
      accounts_renderer.stub(:render).with(accounts).and_return(accounts_json)
      accounts_renderer.stub(:render).with(account).and_return(account_json)
    end

    describe Scrooge::Actions::Accounts::List do
      subject { Scrooge::Actions::Accounts::List.new(accounts_repository, accounts_renderer) }

      it 'lists all accounts' do
        response = req
        expect(response).to be_ok
        expect(response.body).to eq(accounts_json)
      end
    end

    describe Scrooge::Actions::Accounts::Show do
      subject { Scrooge::Actions::Accounts::Show.new(accounts_repository, accounts_renderer) }

      context 'when the account exists' do
        it 'returns the account' do
          response = req(account_id: account_id)
          expect(response).to be_ok
          expect(response.body).to eq(account_json)
        end
      end

      context 'when the account doesn\'t exist' do
        it 'returns a 404' do
          response = req(account_id: wrong_account_id)
          expect(response.status).to eq(404)
        end
      end
    end

    describe Scrooge::Actions::Accounts::Update do
      subject { Scrooge::Actions::Accounts::Update.new(accounts_repository, accounts_renderer) }
      let(:new_name) { 'new account name' }

      context 'when the account exists' do
        context 'when params are valid' do
          it 'updates the account' do
            account.should_receive(:set).with('name' => new_name)
            accounts_repository.should_receive(:update).with(account).and_return(true)

            response = req({ account_id: account_id }, { 'name' => new_name })

            expect(response).to be_ok
            expect(response.body).to eq(account_json)
          end
        end

        context 'when params are invalid' do
          it 'returns a 400 Bad Request and doesn\'t update the account' do
            account.should_receive(:set).with('name' => new_name)
            accounts_repository.should_receive(:update).with(account).and_return(false)

            response = req({ account_id: account_id }, { 'name' => new_name })

            expect(response.status).to eq(400)
          end
        end
      end

      context 'when the account doesn\'t exist' do
        it 'returns a 404 Not Found' do
          response = req({ account_id: wrong_account_id }, { 'name' => new_name })

          expect(response.status).to eq(404)
        end
      end
    end

    describe Scrooge::Actions::Accounts::Create do
      subject { Scrooge::Actions::Accounts::Create.new(accounts_repository, accounts_renderer) }
      let(:name) { 'name' }

      context 'when params are valid' do
        it 'creates a new account' do
          accounts_repository.should_receive(:create).with('name' => name).and_return(account)

          response = req({}, { 'name' => name })

          expect(response.status).to eq(201)
          expect(response.body).to eq(account_json)
        end
      end

      context 'when params are invalid' do
        it 'returns a 400 Bad Request and doesn\'t create an account' do
          accounts_repository.should_receive(:create).with('name' => name).and_return(nil)

          response = req({}, { 'name' => name })

          expect(response.status).to eq(400)
        end
      end
    end

    describe Scrooge::Actions::Accounts::Delete do
      subject { Scrooge::Actions::Accounts::Delete.new(accounts_repository, accounts_renderer) }

      context 'when the objects exists' do
        context 'when the operation succeeds' do
          it 'destroys the object' do
            accounts_repository.should_receive(:destroy).with(account).and_return(true)

            response = req(account_id: account_id)

            expect(response).to be_ok
            expect(response.body).to eq(account_json)
          end
        end

        context 'when the operation fails' do
          it 'returns a 400 Bad Request and doesn\'t destroy the object' do
            accounts_repository.should_receive(:destroy).with(account).and_return(false)

            response = req(account_id: account_id)

            expect(response.status).to eq(400)
          end
        end
      end

      context 'when the object doesn\'t exist' do
        it 'returns a 404 Not Found' do
          response = req(account_id: wrong_account_id)

          expect(response.status).to eq(404)
        end
      end
    end
  end

  describe Scrooge::Actions::Transactions do
    let(:transactions) { double('transactions') }
    let(:transactions_renderer) { 'transactions renderer' }
    let(:transactions_json) { 'transactions json' }

    before do
      account.stub(:transactions).and_return(transactions)
    end

    subject { Scrooge::Actions::Transactions::List.new(accounts_repository, transactions_renderer) }

    it 'lists all transactions from an account' do
      transactions_renderer.should_receive(:render).with(transactions).and_return(transactions_json)

      response = req(account_id: account_id)
      expect(response.status).to eq(200)
      expect(response.body).to eq(transactions_json)
    end
  end

end
