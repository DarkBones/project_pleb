class SchedulesController < ApplicationController
  def index
    @schedules = current_user.schedules.where("is_active = true AND pause_until_utc IS NULL AND type_of != 'main'").order(:next_occurrence).decorate
    @paused_schedules = current_user.schedules.where("is_active = true AND pause_until_utc IS NOT NULL").order(:pause_until_utc).decorate
    @inactive_schedules = current_user.schedules.where(:is_active => 0).order(:next_occurrence).decorate
    @main_schedule = current_user.schedules.where("type_of = 'main'").decorate

  end

  def create

    @schedule = Schedule.create_from_form(schedule_params, current_user).decorate
    @schedule.save if @schedule.is_a?(ActiveRecord::Base)
    #redirect_back(fallback_location: root_path)

    @budget = DailyBudget.recalculate(current_user)
  end

  def run_schedules(datetime=nil, schedules=nil)
    transactions = Schedule.run_schedules(date, schedules)
    return transactions
  end

  def pause

    schedule = current_user.schedules.friendly.find(params[:id])
    @schedule = Schedule.pause(pause_params, schedule, current_user).decorate
    #redirect_back(fallback_location: root_path)

    Schedule.invalidate_scheduled_transactions_cache(current_user)
    @budget = DailyBudget.recalculate(current_user)
  end

  def edit
    @schedule = current_user.schedules.friendly.find(params[:id])
    update_params = Schedule.edit(schedule_params, @schedule)
    @schedule.update(update_params)

    tz = validate_timezone(@schedule.timezone)
    next_occurrence = Schedule.next_occurrence(@schedule, return_datetime: true)

    next_occurrence_local = nil
    next_occurrence_local = tz.utc_to_local(next_occurrence).to_date unless next_occurrence.nil?

    @schedule.next_occurrence = next_occurrence_local
    @schedule.next_occurrence_utc = next_occurrence
    @schedule.save

    @schedule = @schedule.decorate
    
    Schedule.invalidate_scheduled_transactions_cache(current_user)
    @budget = DailyBudget.recalculate(current_user)
  end

  def delete

    @schedule_id = params[:id]
    @schedule = current_user.schedules.friendly.find(params[:id])
    unless @schedule.nil?
      schedule = current_user.schedules.friendly.find(@schedule_id)
      
      SchedulesTransaction.where(schedule_id: schedule.id).each do |sch_t|
        txn = current_user.transactions.find_by_id(sch_t.transaction_id)
        Transaction.delete(txn, current_user) unless txn.nil?
        
        sch_t.destroy
      end

      current_user.transactions.where(schedule_id: schedule.id).each do |transaction|
        unless transaction.is_scheduled
          transaction.schedule_id = nil
          transaction.save
        end
      end
      
      schedule.destroy
    end

    Schedule.invalidate_scheduled_transactions_cache(current_user)
    @budget = DailyBudget.recalculate(current_user)
  end

  def delete_all
    current_user.schedules.destroy_all
    
    Schedule.invalidate_scheduled_transactions_cache(current_user)
    @budget = DailyBudget.recalculate(current_user)
  end

private
  
  def schedule_params
    params.require(:schedule).permit(
      :name,
      :type,
      :start_date,
      :timezone,
      :schedule,
      :run_every,
      :days,
      :days2,
      :dates_picked,
      :weekday_mon,
      :weekday_tue,
      :weekday_wed,
      :weekday_thu,
      :weekday_fri,
      :weekday_sat,
      :weekday_sun,
      :end_date,
      :weekday_exclude_mon,
      :weekday_exclude_tue,
      :weekday_exclude_wed,
      :weekday_exclude_thu,
      :weekday_exclude_fri,
      :weekday_exclude_sat,
      :weekday_exclude_sun,
      :dates_picked_exclude,
      :exclusion_met1,
      :exclusion_met2,
      :occurrence_count,
      :type_of
      )
  end

  def pause_params
    params.require(:schedule).permit(:id, :pause_until)
  end

end
