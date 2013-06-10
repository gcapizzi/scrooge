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

    describe Actions::ListAccounts do
      let(:list_accounts) { Actions::ListAccounts.new(accounts_repository, accounts_renderer) }
      let(:response) { [200, [accounts_json]] }

      it 'lists all accounts' do
        expect(list_accounts.call).to eq(response)
      end
    end

    describe Actions::ShowAccount do
      let(:show_account) { Actions::ShowAccount.new(accounts_repository, accounts_renderer) }
      let(:response) { [200, [account_json]] }
      let(:not_found) { [404, []] }

      it 'shows a single account' do
        expect(show_account.call(account_id)).to eq(response)
      end

      it 'returns a 404 if the accounts doesn\'t exist' do
        expect(show_account.call(wrong_account_id)).to eq(not_found)
      end
    end

    describe Actions::UpdateAccount do
      let(:update_account) { Actions::UpdateAccount.new(accounts_repository, accounts_renderer) }

      context 'when the account exists' do
        context 'when params are valid' do
          let(:response) { [200, [account_json]] }

          it 'updates the account' do
            new_name = 'new account name'
            account.should_receive(:name=).with(new_name)
            accounts_repository.should_receive(:update).with(account).and_return(true)

            expect(update_account.call(account_id, name: new_name)).to eq(response)
          end
        end

        context 'when params are invalid' do
          let(:response) { [406, []] }

          it 'returns a 406 Not Acceptable and doesn\'t update the account' do
            name = 'an invalid name'
            account.should_receive(:name=).with(name)
            accounts_repository.should_receive(:update).with(account).and_return(false)

            expect(update_account.call(account_id, name: name)).to eq(response)
          end
        end
      end

      context 'when the account doesn\'t exist' do
        let(:response) { [404, []] }

        it 'returns a 404 Not Found' do
          expect(update_account.call(wrong_account_id, name: 'anything')).to eq(response)
        end
      end
    end

    describe Actions::CreateAccount do
      let(:create_account) { Actions::CreateAccount.new(accounts_repository, accounts_renderer) }
      let(:response) { [201, [account_json]] }

      context 'when params are valid' do
        it 'creates a new account' do
          name = 'a name'
          accounts_repository.should_receive(:create).with(name: name).and_return(account)

          expect(create_account.call(name: name)).to eq(response)
        end
      end

      context 'when params are invalid' do
        let(:response) { [406, []] }

        it 'returns a 406 Not Acceptable and doesn\'t create an account' do
          name = 'an invalid name'
          accounts_repository.should_receive(:create).with(name: name).and_return(nil)

          expect(create_account.call(name: name)).to eq(response)
        end
      end
    end

    describe Actions::DeleteAccount do
      let(:delete_account) { Actions::DeleteAccount.new(accounts_repository, accounts_renderer) }

      context 'when the objects exists' do
        context 'when the operation succeeds' do
          let(:response) { [200, [account_json]] }

          it 'destroys the object' do
            accounts_repository.should_receive(:destroy).with(account).and_return(true)

            expect(delete_account.call(account_id)).to eq(response)
          end
        end

        context 'when the operation fails' do
          let(:response) { [406, []] }

          it 'returns a 406 Not Acceptable and doesn\'t destroy the object' do
            accounts_repository.should_receive(:destroy).with(account).and_return(false)

            expect(delete_account.call(account_id)).to eq(response)
          end
        end
      end

      context 'when the object doesn\'t exist' do
        let(:response) { [404, []] }

        it 'returns a 404 Not Found' do
          expect(delete_account.call(wrong_account_id)).to eq(response)
        end
      end
    end
  end
end
