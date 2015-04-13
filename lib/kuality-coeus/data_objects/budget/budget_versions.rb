class BudgetVersionsObject < DataFactory

  include StringFactory

  attr_reader :document_id, :status, :summary, :modular,
              :project_start_date, :project_end_date, :total_direct_cost_limit,
              :budget_periods, :unrecovered_fa_rate_type, :f_and_a_rate_type,
              :submit_cost_sharing, :residual_funds, :total_cost_limit,
              :subaward_budgets, :personnel, :institute_rates, :on_off_campus
  attr_accessor :name

  def_delegator :@budget_periods, :period
  def_delegator :@personnel, :person

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      name:              random_alphanums(40), # System can't currently handle this char set: random_alphanums_plus(40),
      budget_periods:    collection('BudgetPeriods'),
      subaward_budgets:  collection('SubawardBudget'),
      personnel:         collection('BudgetPersonnel'),
      summary:           'Y',
      institute_rates:   collection('BudgetRates')
    }

    set_options(defaults.merge(opts))
    requires :navigate
    @open_budget = open_budget
  end

  def create
    @navigate.call
    on(ProposalSidebar).budget
    on(Budgets).add_budget
    on BudgetWizard do |add|
      add.name.wait_until_present
      add.name.set @name
      add.type @summary
      # This only appears when the sponsor is NIH...
      add.modular(@modular) unless @modular.nil?
      add.create_budget
    end
    view 'Budget Settings'
    on BudgetSettings do |page|
      @project_start_date = Utilities.datify(page.project_start_date)
      @project_end_date = Utilities.datify(page.project_end_date)
      fill_out page, :total_direct_cost_limit, :total_cost_limit, :residual_funds, :submit_cost_sharing
      @total_direct_cost_limit |= page.total_direct_cost_limit.value
      @residual_funds |= page.residual_funds.value
      @total_cost_limit |= page.total_cost_limit.value
      @submit_cost_sharing |= page.submit_cost_sharing
      get_or_select! :@unrecovered_fa_rate_type, page.unrecovered_fa_rate_type
      get_or_select! :@f_and_a_rate_type, page.f_and_a_rate_type
      get_or_select! :@status, page.status
      get_or_select! :@on_off_campus, page.on_off_campus
    end
    get_rates
    get_budget_periods
  end #create

  def add_period opts={}
    @budget_periods.add(opts)
    @budget_periods[-1].get_rates @institute_rates
    return if on(PeriodsAndTotals).errors.size > 0 # No need to continue the method if we have an error
    @budget_periods.number! # This updates the number value of all periods, as necessary
  end

  def edit_period number, opts={}
    @budget_periods.period(number).edit opts
    @budget_periods.number!
  end

  def delete_period number
    @budget_periods.period(number).delete
    @budget_periods.delete(@budget_periods.period(number))
    @budget_periods.number!
  end

  def edit opts={}
    raise 'This method needs work!'
    view 'Some thing goes here'
    on Stuff do |edit|
      edit.parameters unless edit.parameters_button.parent.class_name=='tabright tabcurrent'
      edit_fields opts, edit, :final, :total_direct_cost_limit
      edit.budget_status.fit opts[:status]
      # TODO: More to add here...
      edit.save
    end
    set_options(opts)
  end

  def view(tab)
    @open_budget.call
    on(BudgetSidebar).send(damballa(tab.to_s))
  end

  def copy_all_periods new_name
    view 'Periods And Totals'
    on(NewDocumentHeader).budget_versions
    on(BudgetsDialog).copy @name
    on CopyThisBudgetVersion do |page|
      page.budget_name.set new_name
      page.copy_periods 'Y'
      page.copy_budget
    end
    new_bv = self.data_object_copy
    new_bv.name=new_name
    new_bv
  end

  def reset_to_period_defaults
    view 'Periods And Totals'
    on PeriodsAndTotals do |page|
      page.reset_to_period_defaults
      page.save
    end
    get_budget_periods
  end

  def add_subaward_budget(opts={})
    view 'Something'
    on(Parameters).budget_actions
    sab = make SubawardBudgetObject, opts
    sab.create
    @subaward_budgets << sab
  end

  def add_project_personnel(opts={})
    view 'Project Personnel'
    person = make BudgetPersonnelObject, opts
    person.create
    @personnel << person
  end

  def sync_personnel_from_proposal
    view 'Project Personnel'
    on BudgetPersonnel do |page|
      page.sync_from_proposal
      page.added_personnel.each do |full_name|
        person = make BudgetPersonnelObject, full_name: full_name,
                   job_code: page.job_code_of(full_name),
                   appointment_type: page.appointment_type_of(full_name),
                   base_salary: page.salary_of(full_name)
        @personnel << person
      end
    end
  end

  def include_for_submission
    @navigate.call
    on(ProposalSidebar).budget
    on(Budgets).include_for_submission @name
  end

  def save_and_apply_to_other(period, line_item)

  end

  def complete
    view 'Periods And Totals'
    on(PeriodsAndTotals).complete_budget
    on CompleteBudget do |page|
      page.ready.set
      page.ok
    end





    raise 'There is currently a refresh issue, here. The Budget may not actually be "complete", yet.'





  end

  def update_from_parent(navigate_method)
    @navigate=navigate_method
  end

  # =======
  private
  # =======

  def open_budget
    lambda{
      begin
        there = on(NewDocumentHeader).document_title[/: .+/]==": #{@name}"
      rescue Watir::Exception::UnknownObjectException
        there = false
      end
      unless there
        @navigate.call
        on(ProposalSidebar).budget
        on(Budgets).open @name
      end
    }
  end

  # Note: Assumes we're already on the Periods And Totals page...
  def get_budget_periods
    @budget_periods.clear
    view 'Periods and Totals'
    on PeriodsAndTotals do |page|
      1.upto(page.period_count) do |number|
        period = make BudgetPeriodObject, open_budget: @open_budget,
                      start_date: page.start_date_of(number).value,
                      end_date: page.end_date_of(number).value,
                      total_sponsor_cost: page.total_sponsor_cost_of(number).value.groom,
                      direct_cost: page.direct_cost_of(number).value.groom,
                      f_and_a_cost: page.f_and_a_cost_of(number).value.groom,
                      unrecovered_f_and_a: page.unrecovered_f_and_a_of(number).value.groom,
                      cost_sharing: page.cost_sharing_of(number).value.groom,
                      cost_limit: page.cost_limit_of(number).value.groom,
                      direct_cost_limit: page.direct_cost_limit_of(number).value.groom
        period.get_rates(@institute_rates)
        @budget_periods << period
      end
    end
    @budget_periods.number!
  end

  def get_rates
    view 'Rates'
    @institute_rates.build(on(Rates).rates, @project_start_date, @project_end_date, @on_off_campus, @unrecovered_fa_rate_type, @f_and_a_rate_type)
  end

end # BudgetVersionsObject

class BudgetVersionsCollection < CollectionsFactory

  contains BudgetVersionsObject

  def budget(name)
    self.find { |budget| budget.name==name }
  end

  def complete
    self.find { |budget| budget.status=='Complete' }
  end

end # BudgetVersionsCollection