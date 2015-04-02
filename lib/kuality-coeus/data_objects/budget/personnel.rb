class BudgetPersonnelObject < DataFactory

  include StringFactory, Utilities

  attr_reader :type, :full_name, :job_code, :appointment_type, :base_salary,
              :salary_effective_date, :salary_anniversary_date

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        # Note: 'type' must be one of:
        # 'Employee', 'Non Employee', or 'To Be Named'
        type:             'Employee',
        base_salary:      random_dollar_value(1000000)
    }

    set_options(defaults.merge(opts))
  end

  def create
    # Navigation is handled by the BudgetVersionsObject method
    on(BudgetPersonnel).add_personnel
    on AddProjectPersonnel do |page|
      page.search_for.fit @type
      if @full_name.nil?
        page.last_name.set("*#{%w{b c g h k l p r w}.sample}*")
        page.search
        # We need to exclude the set of test users from the list
        # of names we'll randomly select from...
        names = page.returned_full_names - $users.full_names
        name = 'William Lloyd Garrison'
        while name.scan(' ').size != 1
          name = names.sample
        end
        @full_name = name
        page.select_person name
        page.add_selected_personnel
      else
        page.last_name.set @full_name[/\w+$/]
        page.first_name.set @full_name[/^\w+/]
        page.search
        page.check_person @full_name
        page.add_selected_personnel
      end
    end
    on(BudgetPersonnel).details_of @full_name
    on EditPersonnel do |page|
      if page.base_salary.value == '0.00'
        page.base_salary.set @base_salary
      else
        @base_salary = page.base_salary.value
      end
      fill_out page, :job_code, :appointment_type,
               :salary_anniversary_date, :salary_effective_date
      # These lines are here because we want to get the
      # preset values of these fields in case we aren't
      # actually setting them with the data object's creation...
      @job_code = page.job_code.value
      @appointment_type = page.appointment_type.selected_options[0].text
      @salary_effective_date = page.salary_effective_date.value
      page.save_changes
    end
    on(BudgetPersonnel).save
  end

  def edit opts={}
    on page_class do |update|
      update.expand_all
      # TODO: This will eventually need to be fixed...
      # Note: This is a dangerous short cut, as it may not
      # apply to every field that could be edited with this
      # method...

      opts.each do |field, value|
        update.send(field, @full_name).fit value
      end
      update.save
    end
    update_options(opts)
  end

  def monthly_base_salary
    @base_salary.to_f/Transforms::MONTHS[@appointment_type]
  end

end # BudgetPersonnelObject

class BudgetPersonnelCollection < CollectionsFactory

  contains BudgetPersonnelObject

  def full_names
    self.collect { |person| person.full_name }
  end

  def person(name)
    self.find { |person| person.full_name==name }
  end

end