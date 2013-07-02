require './app/actions'

module Scrooge

  describe Actions do
    let(:accounts_repository) { double('accounts repository', attributes: [:name]) }
    let(:accounts_renderer) { double('accounts renderer') }
    let(:accounts) { double('accounts') }
    let(:account_id) { '123' }
    let(:wrong_account_id) { '456' }
    let(:account) { double('account') }
    let(:account_json) { 'account json' }
    let(:accounts_json) { 'accounts json' }

    before do
      accounts_repository.stub(:all).and_return(accounts)
      accounts_repository.stub(:get).with(account_id.to_i).and_return(account)
      accounts_repository.stub(:get).with(wrong_account_id.to_i).and_return(nil)
      accounts_renderer.stub(:render).with(accounts).and_return(accounts_json)
      accounts_renderer.stub(:render).with(account).and_return(account_json)
    end

    def req(app, url_params = {}, params = {})
      Rack::MockRequest.new(app).request('', '', params: params, 'rack.routing_args' => url_params)
    end

    describe Actions::ListAccounts do
      let(:list_accounts) { Actions::ListAccounts.new(accounts_repository, accounts_renderer) }

      it 'lists all accounts' do
        response = req(list_accounts)
        expect(response).to be_ok
        expect(response.body).to eq(accounts_json)
      end
    end

    describe Actions::ShowAccount do
      let(:show_account) { Actions::ShowAccount.new(accounts_repository, accounts_renderer) }

      context 'when the account exists' do
        it 'returns the account' do
          response = req(show_account, { :account_id => account_id })
          expect(response).to be_ok
          expect(response.body).to eq(account_json)
        end
      end

      context 'when the account doesn\'t exist' do
        it 'returns a 404' do
          response = req(show_account, { :account_id => wrong_account_id })
          expect(response.status).to eq(404)
        end
      end
    end

    describe Actions::UpdateAccount do
      let(:update_account) { Actions::UpdateAccount.new(accounts_repository, accounts_renderer) }
      let(:new_name) { 'new account name' }

      context 'when the account exists' do
        context 'when params are valid' do
          it 'updates the account' do
            account.should_receive(:name=).with(new_name)
            accounts_repository.should_receive(:update).with(account).and_return(true)

            response = req(update_account, { :account_id => account_id }, { 'name' => new_name, 'filtered' => 'param' })

            expect(response).to be_ok
            expect(response.body).to eq(account_json)
          end
        end

        context 'when params are invalid' do
          it 'returns a 400 Bad Request and doesn\'t update the account' do
            account.should_receive(:name=).with(new_name)
            accounts_repository.should_receive(:update).with(account).and_return(false)

            response = req(update_account, { :account_id => account_id }, { 'name' => new_name })

            expect(response.status).to eq(400)
          end
        end
      end

      context 'when the account doesn\'t exist' do
        it 'returns a 404 Not Found' do
          response = req(update_account, { :account_id => wrong_account_id }, { 'name' => new_name })

          expect(response.status).to eq(404)
        end
      end
    end

    describe Actions::CreateAccount do
      let(:create_account) { Actions::CreateAccount.new(accounts_repository, accounts_renderer) }
      let(:name) { 'name' }

      context 'when params are valid' do
        it 'creates a new account' do
          accounts_repository.should_receive(:create).with('name' => name).and_return(account)

          response = req(create_account, {}, { 'name' => name, 'filtered' => 'param' })

          expect(response.status).to eq(201)
          expect(response.body).to eq(account_json)
        end
      end

      context 'when params are invalid' do
        it 'returns a 400 Bad Request and doesn\'t create an account' do
          accounts_repository.should_receive(:create).with('name' => name).and_return(nil)

          response = req(create_account, {}, { 'name' => name })

          expect(response.status).to eq(400)
        end
      end
    end

    describe Actions::DeleteAccount do
      let(:delete_account) { Actions::DeleteAccount.new(accounts_repository, accounts_renderer) }

      context 'when the objects exists' do
        context 'when the operation succeeds' do
          it 'destroys the object' do
            accounts_repository.should_receive(:destroy).with(account).and_return(true)

            response = req(delete_account, { :account_id => account_id })

            expect(response).to be_ok
            expect(response.body).to eq(account_json)
          end
        end

        context 'when the operation fails' do
          it 'returns a 400 Bad Request and doesn\'t destroy the object' do
            accounts_repository.should_receive(:destroy).with(account).and_return(false)

            response = req(delete_account, { :account_id => account_id })

            expect(response.status).to eq(400)
          end
        end
      end

      context 'when the object doesn\'t exist' do
        it 'returns a 404 Not Found' do
          response = req(delete_account, { :account_id => wrong_account_id })

          expect(response.status).to eq(404)
        end
      end
    end
  end
end
