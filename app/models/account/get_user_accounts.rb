class Account
  class GetUserAccounts

    def initialize(params, current_user)
      @id = params[:id]
      @account_name = get_account_name(params[:id])
      @transactions = get_transactions(params[:id], current_user)
    end

    def perform
      result = { :id => @id, :account_name => @account_name, :transactions => @transactions }
    end

    private

    def get_account_name(id)
      result = id
      if id != 'all'
        result = Account.find(id).name
      end
    end

    def get_transactions(id, current_user)
      if id != 'all'
        transactions = Transaction.where("account_id" => id, "user_id" => current_user.id).order(:created_at).reverse_order()
      else
        transactions = Transaction.where("user_id" => current_user.id).order(:created_at).reverse_order()
      end
    end

  end

end
