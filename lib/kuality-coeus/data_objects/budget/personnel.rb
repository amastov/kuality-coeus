class BudgetPersonnelObject

  include Foundry
  include DataFactory
  include StringFactory
  include Navigation
  include Utilities

  attr_accessor :type, :name, :job_code, :appointment_type, :base_salary,
                :salary_effective_date, :salary_anniversary_date,
                # TODO: Some day we are going to have to allow for multiple codes and periods, here...
                :object_code_name, :start_date, :end_date, :percent_effort, :percent_charged,
                :period_type, :requested_salary, :calculated_fringe
                #TODO: Add more variables here - "apply inflation", "submit cost sharing", etc.

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        # Note: 'type' must be one of:
        # 'employee', 'non_employee', or 'to_be_named'
        type:             'employee',
        base_salary:      random_dollar_value(1000000),
        appointment_type: '12M DURATION',
        object_code_name: '::random::',
        percent_effort:   random_percentage,
        period_type:      '::random::'
    }

    set_options(defaults.merge(opts))
    @percent_charged ||= (@percent_effort.to_f/2).round(2)
  end

  def create
    # Navigation is handled by the BudgetVersionsObject method
    if on(Personnel).job_code(@name).present?
      # The person is already listed so do nothing
    else
      get_person
    end
    set_job_code
    on Personnel do |page|
      @salary_effective_date ||= page.salary_effective_date(@name).value
      fill_out_item @name, page, :appointment_type, :base_salary, :salary_effective_date,
                    :salary_anniversary_date
      page.save
      page.expand_all
      page.person.select "#{@name} - #{@job_code}"
      sleep 1 # this is required because the select list contains get updated when the person is selected.
      page.object_code_name.pick! @object_code_name
      page.add_details
      page.expand_all
      set_dates page
      fill_out_item @name, page, :percent_effort, :percent_charged, :period_type
      page.calculate @name
      @requested_salary=page.requested_salary @name
      @calculated_fringe=page.calculated_fringe @name
      page.save
    end
  end

  # ========
  private
  # ========

  def set_job_code
    unless @job_code.nil?
      on(Personnel).job_code(@name).set @job_code
    else
      on(Personnel).lookup_job_code(@name)
      on JobCodeLookup do |page|
        page.search
        page.return_random
      end
      @job_code=on(Personnel).job_code(@name).value
    end
  end

  def get_person
    on(Personnel).send("#{@type}_search")
    if @name.nil?
      on lookup_page do |page|
        page.search
        @name=page.returned_full_names.sample
      end
    end
    on lookup_page do |page|
      case(@type)
        when 'employee'
          page.select_person @name
        when 'non_employee'
          page.first_name.set @name[/^\S+/]
          page.last_name.set @name[/\S+$/]
          page.search
          page.select_person @name[/\S+$/]
        when 'to_be_named'
          page.person_name.set @name
          page.search
          page.select_person @name
      end
      page.return_selected
    end
  end

  # TODO: WOW! This desperately needs to be dryed up!
  # It might be a good idea to make a new method in
  # TestFactory for this.
  def set_dates(page)
    if @start_date.nil?
      @start_date=page.start_date(@name).value
    else
      page.start_date(@name).set @start_date
    end
    if @end_date.nil?
      @end_date=page.end_date(@name).value
    else
      page.end_date(@name).set @end_date
    end
  end

  def lookup_page
    Kernel.const_get({
        employee:     'PersonLookup',
        non_employee: 'NonOrgAddressBookLookup',
        to_be_named:  'ToBeNamedPersonsLookup'
    }[@type.to_sym])
  end

end

class BudgetPersonnelCollection < CollectionsFactory

  contains BudgetPersonnelObject

end