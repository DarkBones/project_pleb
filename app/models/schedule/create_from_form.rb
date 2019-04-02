class Schedule
  class CreateFromForm
    
    def initialize(params, current_user, testing=false)
      @params = params[:schedule]
      @current_user = current_user

      @excluding = false
      @testing = testing
    end

    def perform
      @params[:name] = sanitise_name(@params[:name])
      error = check_errors
      return error[:message] if error[:is_error]

      schedule_params = {
        name: @params[:name],
        start_date: @params[:start_date].to_date,
        end_date: get_end_date,
        period: get_period,
        period_num: @params[:run_every],
        days: get_days,
        days_month: get_days_month,
        days_month_day: get_month_day,
        days_exclude: get_days_exclude,
        exclusion_met: get_exclusion_met,
        exclusion_met_day: get_exclusion_met_day,
        timezone: @params[:timezone],
        is_active: get_is_active
      }

      #schedule = Schedule.new(schedule_params)
      schedule = @current_user.schedules.new(schedule_params)
      return schedule
    end

    def sanitise_name(name_str)
      # don't allow dots in schedule name
      return name_str.gsub '.', ''
    end

    def check_errors
      return {message: I18n.t('schedule.failure.invalid_name'), is_error: true} if @params[:name].length == 0

      # check if start_date is valid
      date_regex = APP_CONFIG['ui']['dates']['regex']
      return {message: I18n.t('schedule.failure.invalid_date'), is_error: true} if /#{date_regex}/.match(@params[:start_date].downcase) == nil

      # if the end_date format is invalid, just leave it empty
      @params[:end_date] = '' if /#{date_regex}/.match(@params[:end_date].downcase) == false

      # check if the period_num is valid
      if @params[:run_every].respond_to? :to_i
        if @params[:run_every].to_i < 1
          @params[:run_every] = 1
        end
      else
        return {message: I18n.t('schedule.failure.unknown'), is_error: true}
      end

      # check if the schedule already exists
      schedules = @current_user.schedules.where("LOWER(schedules.name) LIKE LOWER(?)", @params[:name]).take
      if schedules && !@testing
        return {message: I18n.t('schedule.failure.already_exists'), is_error: true}
      end

      return {message: 'no errors', is_error: false}

    end

    def get_is_active
      return Time.now.to_date < @params[:end_date].to_date if @params[:end_date].length >= 11
      return true
    end

    def get_end_date
      if @params[:end_date].length > 0 && @params[:type] == 'advanced'
        return @params[:end_date].to_date
      else
        return ''
      end
    end

    def get_days_month
      days_month = ''
      if @params[:type] == 'advanced'
        days_month = @params[:days]
      end
      return days_month
    end

    def get_month_day
      weekdays = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']

      month_day = 0
      if @params[:schedule] == 'monthly' && @params[:days] != 'specific' && @params[:type] == 'advanced'
        month_day = weekdays.index(@params[:days2])
      end
      return month_day
    end

    def get_exclusion_met
      met = ''

      if @params[:schedule] == 'monthly' && @excluding == true && @params[:type] == 'advanced'
        met = @params[:exclusion_met1]
      end

      return met
    end

    def get_exclusion_met_day
      weekdays = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']

      met = 0

      if @params[:schedule] == 'monthly' && @excluding == true && @params[:type] == 'advanced'
        met = weekdays.index(@params[:exclusion_met2])
      end

      return met
    end

    def get_days_exclude
      bitmask = 0b0
      if @params[:type] == 'advanced'
        if @params[:schedule] == 'monthly'
          
          if @params[:days] == 'specific' || (@params[:days] != 'specific' && @params[:days2] == 'day')
            bitmask = get_weekday_bitmask([
              'weekday_exclude_sun',
              'weekday_exclude_mon',
              'weekday_exclude_tue',
              'weekday_exclude_wed',
              'weekday_exclude_thu',
              'weekday_exclude_fri',
              'weekday_exclude_sat'])
          else
            bitmask = get_month_bitmask(@params[:dates_picked_exclude])
          end

        end

        @excluding = true if bitmask > 0
      end

      return bitmask
    end

    def get_period
      result = case @params[:schedule]
      when 'daily' then 'days'
      when 'weekly' then 'weeks'
      when 'monthly' then 'months'
      else 'years'
      end

      return result
    end

=begin
    def get_days

      bitmask = 0b0

      if @params[:type] == 'advanced'
        if @params[:schedule] == 'weekly'
          bitmask = get_weekday_bitmask([
            'weekday_sun',
            'weekday_mon',
            'weekday_tue',
            'weekday_wed',
            'weekday_thu',
            'weekday_fri',
            'weekday_sat'])
        elsif @params[:schedule] == 'monthly' && @params[:days] == 'specific'
          bitmask = get_month_bitmask(@params[:dates_picked])
          if bitmask == 0
            bitmask = 0b0
            bitmask = bitmask | (1 << @params[:start_date].to_date.day)
          end
        elsif @params[:schedule] == 'monthly' && @params[:days] != 'specific' && @params[:days2] != 'day'
          weekdays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
          bitmask = 0b0 | (1 << weekdays.index(@params[:days2]))
        end
      end

      return bitmask
    end
=end

    def get_days
      bitmask = 0b0

      return 0b0 if @params[:type] != 'advanced'

      return get_weekday_bitmask(['weekday_sun', 'weekday_mon', 'weekday_tue', 'weekday_wed', 'weekday_thu', 'weekday_fri', 'weekday_sat']) if @params[:schedule] == 'weekly'

      return get_month_bitmask(@params[:dates_picked]) if @params[:schedule] == 'monthly' && @params[:days] == 'specific'

      if @params[:schedule] == 'monthly' && @params[:days] != 'specific' && @params[:days2] != 'day'
        weekdays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
        return 0b0 | (1 << weekdays.index(@params[:days2]))
      end

      return 0

    end

    def get_weekday_bitmask(weekdays)
      bitmask = 0b0
      weekdays.each_with_index do |d, i|
        if @params[d.to_sym] == '1'
          bitmask = bitmask | (1 << i)
        end
      end
      return bitmask
    end

    def get_month_bitmask(days)
      days = days.strip
      days = days.split(' ')

      bitmask = 0b0
      days.each do |d|
        bitmask = bitmask | (1 << d.to_i)
      end

      if bitmask == 0
        bitmask = 0b0
        bitmask = bitmask | (1 << @params[:start_date].to_date.day)
      end

      return bitmask
    end

  end
end
