class ApiGuiController < BaseApiBrowserController

	def account_display_balance
		render json: "bad request", status: :bad_request and return unless params[:amount] && params[:from] && params[:to] && params[:add]

		begin
			from_currency = Money::Currency.new(params[:from])
			to_currency = Money::Currency.new(params[:to])
		rescue
			render json: "Invalid currency", status: :bad_request and return
		end

		render json: Account.get_display_balance_html(params)
	end

	def new_account_form
		render partial: "accounts/new_account_form"
	end

	def new_transaction_form
		render partial: "transactions/new_transactions_form"
	end

	def new_schedule_form
		render partial: "schedules/new_schedule_form"
	end

	def render_notifications
		render partial: "layouts/notifications"
	end

	def render_transaction
    active_account = Account.get_from_name(params[:account], current_user)
    transaction = current_user.transactions.find(params[:transaction]).decorate

    render partial: 'accounts/transaction', :locals => { :active_account => active_account, :transaction => transaction }
  end

  def render_schedule_transactions
    schedule = current_user.schedules.find(params[:schedule])
    transactions = schedule.user_transactions.where("parent_id is null AND (transfer_transaction_id is null OR (transfer_transaction_id is not null AND direction = -1))").order(:description).decorate
    
    render partial: "schedules/transactionlist", :locals => {:transactions => transactions, :schedule_id => params[:schedule]}
  end

private
	
	def display_balance_params
		params.permit(:account, :amount, :from, :to, :add)
	end

end