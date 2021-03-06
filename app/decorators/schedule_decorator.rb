class ScheduleDecorator < ApplicationDecorator
  delegate_all

  def last_occurrence
    occurrence = ScheduleOccurrence.where(schedule_id: model.id).order(:occurrence_local).reverse_order().take
    return nil unless occurrence
    return occurrence.occurrence_local.to_date
  end

  def time_num
    return 0 if model.next_occurrence.nil?
    if model.is_active == true
      return model.next_occurrence.strftime("%Y%m%d").to_i
    elsif last_occurrence
      return last_occurrence.strftime("%Y%m%d").to_i
    else
      return 0
    end
  end

  def run_date
    if model.is_active == true
      return model.next_occurrence
    else
      return last_occurrence
    end
  end


end
