class AssignedPerson < DataFactory

  include Utilities, DateFactory

  attr_reader :person, :object_code, :group, :start_date,
              :end_date, :percent_effort, :percent_charged,
              :period_type, :requested_salary
  attr_accessor :monthly_base_salary, :inflation_rate, :rate_start_date

  def initialize(browser, opts={})
    @browser = browser
    percent = rand(99)+1
    defaults = {
      object_code:         '::random::',
      group:               'Default',
      percent_effort:      percent.to_s,
      percent_charged:     (percent*0.8).round(2).to_s,
      period_type:         '::random::',
      monthly_base_salary: 0.0,
      # TODO: Don't hard code this:
      inflation_rate:      3.0
    }
    set_options(defaults.merge(opts))
    requires :person
  end

  def create
    # Navigation to this point must be done by the parent Period object
    on AddPersonnelToPeriod do |page|
      # These three fields have been pulled out of the
      # fill_out method because of some sort of
      # low-level bug that causes Selenium to complain
      # that they are no longer in the page DOM.
      # A TODO in the future should be to test adding
      #  these fields back to the fill_out list, to
      # see if the bug has been addressed.
      page.object_code.pick! @object_code
      page.percent_effort.set @percent_effort
      page.percent_charged.set @percent_charged
      page.person.select /#{@person}/
      fill_out page, :group, :start_date, :end_date, :period_type
      @start_date ||= page.start_date.value
      @end_date ||= page.end_date.value
      #TODO: This really needs to be set by either scraping the UI, or a Rates Data Object somehow.
      # For now, just going to keep things simple.
      @rate_start_date ||= "07/01/#{end_d.year}"
      page.assign_to_period
    end
    # FIXME:
    # Because it's possible for there to be multiple people assigned to
    # a single object code, it is inappropriate to select whether to apply
    # inflation to an object code within a single assigned person.
    # As such, this code does not really belong in this method or this class.
    # However, until such time as we have scenarios that test multiple assigned
    # persons in an object code, it's simpler just to have the inflation setup
    # taken care of here...
    on(AssignPersonnelToPeriods).details_and_rates_of @object_code
    on DetailsAndRates do |page|
      fill_out page, :apply_inflation
      page.save_changes
    end
    on(AssignPersonnelToPeriods).save
  end

  def requested_salary
    ((middle_months_count*monthly_calculated_salary) + (monthly_inflation_cost*inflated_months_count) + start_month_calculated_salary + end_month_calculated_salary + end_month_inflation_cost).round(2)
  end

  def cost_sharing
    ((middle_months_count*monthly_calc_cost_share) + start_month_calc_cost_share + em ).round(2)
  end

  def rate_cost(rate)
    (requested_salary*(rate.to_f/100)).round(2)
  end

  def rate_cost_sharing(rate)
    (cost_sharing*(rate.to_f/100)).round(2)
  end

  private

  def start_month_days
    days_prior = start.day-1
    days_in_start_month - days_prior
  end

  def end_month_days
    end_d.day
  end

  def days_in_start_month
    days_in_month(start.year, start.month)
  end

  def start_month_full?
    start.day == 1
  end

  def days_in_end_month
    days_in_month(end_d.year, end_d.month)
  end

  def end_month_full?
    end_month_days == days_in_end_month
  end

  def start_and_end_month_same?
    end_d.year == start.year && end_d.month == start.month
  end

  def monthly_calculated_salary
    monthly_base_salary*perc_chrgd
  end

  def monthly_calc_cost_share
    monthly_base_salary*cost_sharing_percentage
  end

  def monthly_inflation_cost
    monthly_calculated_salary*(@inflation_rate.to_f/100)
  end

  def start_month_daily_salary
    monthly_base_salary/days_in_start_month
  end

  def end_month_daily_salary
    start_and_end_month_same? ? 0 : monthly_base_salary/days_in_end_month
  end

  def start_month_calculated_salary
    start_month_daily_salary*start_month_days*perc_chrgd
  end

  def start_month_calc_cost_share
    start_month_daily_salary*start_month_days*cost_sharing_percentage
  end

  def end_month_calculated_salary
    end_month_daily_salary*end_month_days*perc_chrgd
  end

  def end_mnth_calc_cost_sharing
    end_month_daily_salary*end_month_days*cost_sharing_percentage
  end

  def end_month_inflation_cost
    end_month_calculated_salary*(@inflation_rate.to_f/100)
  end

  def start
    datify @start_date
  end

  def end_d
    datify @end_date
  end

  def rate_start
    datify @rate_start_date
  end

  def middle_months_count
    x = (end_d.year - start.year)*12 + end_d.month - start.month - 1
    x < 0 ? 0 : x
  end

  def inflated_months_count
    x = end_d.month - rate_start.month
    x < 0 ? end_d.month + (12 - rate_start.month) : x
  end

  def perc_chrgd
    @percent_charged.to_f/100
  end

  def cost_sharing_percentage
    (@percent_effort.to_f-@percent_charged.to_f)/100
  end

end

class AssignedPersonnelCollection < CollectionFactory

  contains AssignedPerson

  def person(name)
    self.find { |p| p.person==name }
  end

end