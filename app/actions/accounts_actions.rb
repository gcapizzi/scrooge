require './lib/framework'

module Scrooge
  module Actions

    class ListAccounts  < ListAction;   end
    class ShowAccount   < ShowAction;   end
    class UpdateAccount < UpdateAction; end
    class CreateAccount < CreateAction; end
    class DeleteAccount < DeleteAction; end

  end
end
