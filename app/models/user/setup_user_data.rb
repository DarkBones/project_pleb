class User
  class SetupUserData

  	def initialize(current_user, params)
  		@current_user = current_user
  		@params = params
  	end

  	def perform
  		account_params = get_account_params(@params)
  		income_params = get_income_params(@params)
  		expense_params = get_expense_params(@params)

  		# save the accounts
  		account_params.each do |a|
  			account = @current_user.accounts.new(a)
  			account.save
  		end

  		# save income schedule
  		Schedule.create_income(@current_user, income_params)

  		# save the fixed expenses
  		expense_params.each do |e|
  			Schedule.create_expense(@current_user, e)
  		end
  	end

private

		def get_expense_params(params)
			expenses = []
			params.keys.each do |k|
				if k.starts_with?("periodNum_")
					idx = k.split("_")[-1]
					expenses.push(get_schedule_params(params, idx)) unless idx == "income"
				end
			end

			return expenses
		end

		def get_income_params(params)
			return if params["regularity"] != "regular"

			return get_schedule_params(params, "income", "Income", "income")
		end

		def get_schedule_params(params, idx, schedule_name=nil, category_name=nil)
			schedule_name ||= params["category_#{idx}"]
			category_name ||= params["category_name_#{idx}"]
			
			return {
				category: schedule_name,
				category_name: category_name,
				periodNum: params["periodNum_#{idx}"],
				period: params["period_#{idx}"],
				month_day: params["month_day_#{idx}"],
				month_day2: params["month_day2_#{idx}"],
				month_exclude_wday: params["month_exclude_wday_#{idx}"],
				month_exclude_met: params["month_exclude_met_#{idx}"],
				month_exclude_met_day: params["month_exclude_met_day_#{idx}"],
				week_day: params["week_day_#{idx}"],
				day_date: params["day_date_#{idx}"],
				currency: params["currency_#{idx}"],
				fixed_amount: params["fixed_amount_#{idx}"],
				amount: params["amount_#{idx}"],
				average_amount: params["average_amount_#{idx}"],
				account: params["account_#{idx}"],
				account_average: params["account_average_#{idx}"]
			}
		end

		def get_account_params(params)
			accounts = []

			params.keys.each do |k|
				if k.starts_with?("account_name_")
					idx = k.split("_")[-1]
					account = {
						name: params["account_name_#{idx}"],
						balance: Currency.float_to_int(params["account_balance_#{idx}"], params["account_currency_#{idx}"]),
						currency: params["account_currency_#{idx}"],
						is_default: idx == "0"
					}
					accounts.push(account)
				end
			end

			return accounts
		end

  end
end