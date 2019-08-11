class ApiTransactionsController < BaseApiController

	def show
		render json: "bad request", status: :bad_request and return unless params[:id]

		transaction = @user.transactions.find(params[:id])
		render json: "not found", status: :not_found and return if transaction.nil?

		transaction = JSON.parse(transaction.to_json)
		transaction = prepare_json(transaction)

		render json: transaction
	end

	def cancel_upcoming_occurrence
    transaction = current_user.transactions.find(params[:id])

    return if transaction.nil?
    return if current_user.schedules.find(params[:schedule_id]).nil?
    return unless current_user.transactions.where(scheduled_transaction_id: params[:id], schedule_id: params[:schedule_id], schedule_period_id: params[:schedule_period_id], is_cancelled: true).take.nil?

    Transaction.cancel_upcoming_occurrence(current_user, transaction, params[:schedule_id], params[:schedule_period_id])
  end

  def trigger_upcoming_occurrence
  	transaction = current_user.transactions.find(params[:id])
    schedule = current_user.schedules.find(params[:schedule_id])


    return if transaction.nil?
    return if schedule.nil?

    Transaction.trigger_upcoming_occurrence(current_user, transaction, schedule, params[:schedule_period_id])
  end

end