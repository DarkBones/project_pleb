class Transaction
  class SaveTransactions

    def initialize(transactions, current_user)
      @transactions = transactions
      @current_user = current_user
    end

    def perform
      transactions = []
      transfer_transactions = []

      @transactions.each do |t|
        transfer_account_id = nil
        parent_id = nil

        unless t[:transfer_transaction_id].nil?
          transfer_account_id = @transactions[t[:transfer_transaction_id]][:transfer_account_id]
        end

        transaction = save_transaction(t, @current_user, transfer_account_id, parent_id)

        unless t[:transfer_transaction_id].nil?
          transfer_transactions.push(transaction)
        end

        transactions.push(transaction)

        unless t[:children].nil?
          parent_id = transaction.id

          t[:children].each do |ct|
            transaction = save_transaction(ct, @current_user, transfer_account_id, parent_id)
            transactions.push(transaction)
          end
        end

      end

      if transfer_transactions.length == 2
        transfer_transactions[0].transfer_transaction_id = transfer_transactions[1].id
        transfer_transactions[1].transfer_transaction_id = transfer_transactions[0].id

        transfer_transactions[0].save
        transfer_transactions[1].save
      end

      return transactions

    end

private

    def save_transaction(transaction, current_user, transfer_account_id, parent_id)
      t = current_user.transactions.new

      t.amount = transaction[:amount]
      t.direction = transaction[:direction]
      t.description = transaction[:description]
      t.account_id = transaction[:transfer_account_id]
      t.timezone = transaction[:timezone]
      t.currency = transaction[:currency]
      t.account_currency_amount = transaction[:account_currency_amount]
      t.category_id = transaction[:category_id]
      t.parent_id = parent_id
      t.transfer_account_id = transfer_account_id
      t.user_currency_amount = transaction[:user_currency_amount]

      t.save

      return t
    end

  end
end