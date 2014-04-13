module Nickel
  # Some notes about this class, type can take the following values:
  # :single, :daily, :weekly, :daymonthly, :datemonthly,
  Occurrence = Struct.new(:type, :start_date, :end_date, :start_time, :end_time, :interval, :day_of_week, :week_of_month, :date_of_month) do

    def initialize(h)
      h.each { |k, v| send("#{k}=", v) }
    end

    def inspect
      '#<Occurrence ' + members.select { |m| self[m] }.map { |m| %(#{m}: #{self[m]}) }.join(', ') + '>'
    end

    def finalize(cur_date)
      cur_date = start_date unless start_date.nil?
      case type
        when :daily then finalize_daily(cur_date)
        when :weekly then finalize_weekly(cur_date)
        when :datemonthly then finalize_datemonthly(cur_date)
        when :daymonthly then finalize_daymonthly(cur_date)
      end
    end

    private

    def finalize_daily(cur_date)
      self.start_date = cur_date
    end

    def finalize_weekly(cur_date)
      # this is needed in case someone said "every monday and wed
      # starting DATE"; we want to find the first occurrence after DATE
      self.start_date = cur_date.this(day_of_week)

      unless end_date.nil?
        # find the real end date, if someone says "every monday until
        # dec 1"; find the actual last occurrence
        self.end_date = end_date.prev(day_of_week)
      end
    end

    def finalize_datemonthly(cur_date)
      if cur_date.day <= date_of_month
        self.start_date = cur_date.add_days(date_of_month - cur_date.day)
      else
        self.start_date = cur_date.add_months(1).beginning_of_month.add_days(date_of_month - 1)
      end
    end

    def finalize_daymonthly(cur_date)
      # in this case we also want to change week_of_month val to -1 if
      # it is currently 5.  I used 5 to represent "last" in the
      # previous version of the parser, but a more standard format is
      # to use -1
      self.week_of_month = -1 if week_of_month == 5

      self.start_date = cur_date.get_date_from_day_and_week_of_month(day_of_week, week_of_month)
    end
  end
end
