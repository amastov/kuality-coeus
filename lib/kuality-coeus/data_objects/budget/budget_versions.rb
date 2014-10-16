class BudgetVersionsObject < DataFactory

  include StringFactory

  attr_reader :document_id, :status, :summary, :modular,
              :project_start_date, :project_end_date, :total_direct_cost_limit,
              :budget_periods, :unrecovered_fa_rate_type, :f_and_a_rate_type,
              :submit_cost_sharing, :residual_funds, :total_cost_limit,
              :subaward_budgets, :personnel
  attr_accessor :name, :version

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      name:              random_alphanums(40), # System can't currently handle this char set: random_alphanums_plus(40),
      budget_periods:    collection('BudgetPeriods'),
      subaward_budgets:  collection('SubawardBudget'),
      personnel:         collection('BudgetPersonnel'),
      summary:           'Y',
      modular:           'N'
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
      add.modular @modular
      add.create_budget
    end
    get_budget_periods
  end

  def add_period opts={}
    @budget_periods.add(opts)
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

    on Parameters do |edit|
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

  def copy_all_periods(new_name)
    @open_document.call

    new_version_number='x'
    on(BudgetVersions).copy @name
    on(Confirmation).copy_all_periods
    on BudgetVersions do |copy|
      copy.name_of_copy.set new_name
      copy.save
      new_version_number=copy.version(new_name)
    end
    new_bv = self.clone
    new_bv.name=new_name
    new_bv.version=new_version_number
    new_bv
  end

  def copy_one_period(new_name, version)
    # pending resolution of a bug
  end

  def default_periods
    view 'Periods And Totals'
    on PeriodsAndTotals do |page|
      page.reset_to_period_defaults
    end
    @budget_periods.clear
    get_budget_periods
  end

  def add_subaward_budget(opts={})
    open_budget
    on(Parameters).budget_actions
    sab = make SubawardBudgetObject, opts
    sab.create
    @subaward_budgets << sab
  end

  def add_project_personnel(opts={})
    open_budget
    on(Parameters).personnel
    person = make BudgetPersonnelObject, opts
    person.create
    @personnel << person
  end

  def update_from_parent(navigate_method)
    @navigate=navigate_method
  end

  # =======
  private
  # =======

  def open_budget
    lambda{
      unless on(NewDocumentHeader).document_title[/: .+/]==": #{@name}"
        @navigate.call
        on(ProposalSidebar).budget
        on(Budgets).open @name
      end
    }
  end

  def get_budget_periods
    on PeriodsAndTotals do |page|
      1.upto(page.period_count) do |number|
        page.edit_period number
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
        @budget_periods << period
      end
    end
    @budget_periods.number!
  end

end # BudgetVersionsObject

class BudgetVersionsCollection < CollectionsFactory

  contains BudgetVersionsObject

  def budget(name)
    self.find { |budget| budget.name==name }
  end

  def copy_all_periods(name, new_name)
    self << self.budget(name).copy_all_periods(new_name)
  end

  def complete
    self.find { |budget| budget.status=='Complete' }
  end

end # BudgetVersionsCollection