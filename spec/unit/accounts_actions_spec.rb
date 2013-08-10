require './app/actions/accounts_actions'

describe Scrooge::Actions do
  let(:id) { '123' }
  let(:wrong_id) { '456' }
  let(:account) { double('account', id: id) }
  let(:accounts) { double('accounts') }
  let(:account_json) { 'account json' }
  let(:accounts_json) { 'accounts json' }
  let(:accounts_repository) { double('accounts repository', attributes: [:name]) }
  let(:accounts_renderer) { double('accounts renderer') }

  before do
    accounts_repository.stub(:get).with(id.to_i).and_return(account)
    accounts_repository.stub(:get).with(wrong_id.to_i).and_return(nil)
    accounts_renderer.stub(:render).with(accounts).and_return(accounts_json)
    accounts_renderer.stub(:render).with(account).and_return(account_json)
  end

  describe Scrooge::Actions::ListAccounts do
    subject { Scrooge::Actions::ListAccounts.new(accounts_repository, accounts_renderer) }

    it 'lists all accounts' do
      accounts_repository.stub(:all).and_return(accounts)

      response = make_request

      expect(response).to be_ok
      expect(response.body).to eq(accounts_json)
    end
  end

  describe Scrooge::Actions::ShowAccount do
    subject { Scrooge::Actions::ShowAccount.new(accounts_repository, accounts_renderer) }

    context 'when the account exists' do
      it 'returns the account' do
        response = make_request('id' => id)
        expect(response).to be_ok
        expect(response.body).to eq(account_json)
      end
    end

    context 'when the account doesn\'t exist' do
      it 'returns a 404' do
        response = make_request('id' => wrong_id)
        expect(response.status).to eq(404)
      end
    end
  end

  describe Scrooge::Actions::UpdateAccount do
    subject { Scrooge::Actions::UpdateAccount.new(accounts_repository, accounts_renderer) }
    let(:new_name) { 'new account name' }

    context 'when the account exists' do
      context 'when params are valid' do
        it 'updates the account' do
          account.should_receive(:set).with('id' => id, 'name' => new_name)
          accounts_repository.should_receive(:update).with(account).and_return(true)

          response = make_request('id' => id, 'name' => new_name)

          expect(response).to be_ok
          expect(response.body).to eq(account_json)
        end
      end

      context 'when params are invalid' do
        it 'returns a 400 Bad Request and doesn\'t update the account' do
          account.should_receive(:set).with('id' => id, 'name' => new_name)
          accounts_repository.should_receive(:update).with(account).and_return(false)

          response = make_request('id' => id, 'name' => new_name)

          expect(response.status).to eq(400)
        end
      end
    end

    context 'when the account doesn\'t exist' do
      it 'returns a 404 Not Found' do
        response = make_request('id' => wrong_id, 'name' => new_name)

        expect(response.status).to eq(404)
      end
    end
  end

  describe Scrooge::Actions::CreateAccount do
    subject { Scrooge::Actions::CreateAccount.new(accounts_repository, accounts_renderer) }
    let(:name) { 'name' }

    context 'when params are valid' do
      it 'creates a new account' do
        accounts_repository.should_receive(:create).with('name' => name).and_return(account)

        response = make_request('name' => name)

        expect(response.status).to eq(201)
        expect(response.body).to eq(account_json)
      end
    end

    context 'when params are invalid' do
      it 'returns a 400 Bad Request and doesn\'t create an account' do
        accounts_repository.should_receive(:create).with('name' => name).and_return(nil)

        response = make_request('name' => name)

        expect(response.status).to eq(400)
      end
    end
  end

  describe Scrooge::Actions::DeleteAccount do
    subject { Scrooge::Actions::DeleteAccount.new(accounts_repository, accounts_renderer) }

    context 'when the objects exists' do
      context 'when the operation succeeds' do
        it 'destroys the object' do
          accounts_repository.should_receive(:destroy).with(account).and_return(true)

          response = make_request('id' => id)

          expect(response).to be_ok
          expect(response.body).to eq(account_json)
        end
      end

      context 'when the operation fails' do
        it 'returns a 400 Bad Request and doesn\'t destroy the object' do
          accounts_repository.should_receive(:destroy).with(account).and_return(false)

          response = make_request('id' => id)

          expect(response.status).to eq(400)
        end
      end
    end

    context 'when the object doesn\'t exist' do
      it 'returns a 404 Not Found' do
        response = make_request('id' => wrong_id)

        expect(response.status).to eq(404)
      end
    end
  end

end
