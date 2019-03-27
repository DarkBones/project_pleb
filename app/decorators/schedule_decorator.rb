class ScheduleDecorator < ApplicationDecorator
  delegate_all

  def time_num
    if model.is_active == true
      return model.next_occurrence.strftime("%Y%m%d").to_i
    else
      return model.last_occurrence.strftime("%Y%m%d").to_i
    end
  end

  def run_date
    if model.is_active == true
      return model.next_occurrence
    else
      return model.last_occurrence
    end
  end

end
