class ApiTransactionsController < BaseApiController

	def show
		render json: "bad request", status: :bad_request and return unless params[:id]

		transaction = @user.transactions.friendly.find(params[:id])
		render json: "not found", status: :not_found and return if transaction.nil?
    user_date = User.format_date(transaction.local_datetime.to_date) unless transaction.local_datetime.nil?


		transaction = JSON.parse(transaction.to_json)
		transaction = prepare_json(transaction)
    transaction[:date_user_format] = user_date

		render json: transaction
	end

	def cancel_upcoming_occurrence

    transaction = @user.transactions.friendly.find(params[:id])
    schedule = nil
    schedule = @user.schedules.friendly.find(params[:schedule_id]) if params[:schedule_id].length > 3
    schedule_id = schedule.id unless schedule.nil?

    return if transaction.nil?
    #return if @user.schedules.find(params[:schedule_id]).nil?
    return unless @user.transactions.where(scheduled_transaction_id: params[:id], schedule_id: params[:schedule_id], schedule_period_id: params[:schedule_period_id], is_cancelled: true).take.nil?

    Transaction.cancel_upcoming_occurrence(transaction, schedule_id, params[:schedule_period_id])
    
    Schedule.invalidate_scheduled_transactions_cache(current_user)
    @budget = DailyBudget.recalculate(current_user)
    #redirect_back fallback_location: root_path
  end

  def uncancel_upcoming_occurrence

    transaction = @user.transactions.friendly.find(params[:id])

    return if transaction.nil?
    return if @user.schedules.friendly.find(params[:schedule_id]).nil? if params[:schedule_id].to_i > 3
    return unless @user.transactions.where(scheduled_transaction_id: params[:id], schedule_id: params[:schedule_id], schedule_period_id: params[:schedule_period_id], is_cancelled: true).take.nil?

    Transaction.uncancel_upcoming_occurrence(transaction)
    #redirect_back fallback_location: root_path
    @budget = DailyBudget.recalculate(current_user)
    Schedule.invalidate_scheduled_transactions_cache(current_user)
  end

  def trigger_upcoming_occurrence

  	transaction = @user.transactions.friendly.find(params[:id])
    schedule = nil
    schedule = @user.schedules.friendly.find(params[:schedule_id]) if params[:schedule_id].length > 3

    return if transaction.nil?
    #return if schedule.nil?

    transactions = Transaction.trigger_upcoming_occurrence(@user, transaction, schedule, params[:schedule_period_id])
    
    @budget = DailyBudget.recalculate(current_user)
    Schedule.invalidate_scheduled_transactions_cache(current_user)
    return transactions
    
  end

end
