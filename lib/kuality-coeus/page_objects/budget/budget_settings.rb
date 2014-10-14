class BudgetSettings < BasePage

  # TODO: Finish out defining these, when needed...

  value(:project_start_date) { |b| b.div(data_label: 'Project Start Date').text }
  value(:project_end_date) { |b| b.div(data_label: 'Project End Date').text }
  element(:total_direct_cost_limit) { |b| b.text_field(name: 'name="budget.totalDirectCostLimit"') }
  element(:status) { |b| b.select(name: 'budget.budgetStatus') }
  element(:on_off_campus) { |b| b.select(name: 'budget.onOffCampusFlag') }


end