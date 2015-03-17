class BudgetSettings < BasePage

  buttons 'Apply Changes'

  value(:project_start_date) { |b| b.div(data_label: 'Project Start Date').text }
  value(:project_end_date) { |b| b.div(data_label: 'Project End Date').text }
  element(:total_direct_cost_limit) { |b| b.text_field(name: 'budget.totalDirectCostLimit') }
  element(:total_cost_limit) { |b| b.text_field(name: 'budget.totalCostLimit') }
  element(:status) { |b| b.select(name: 'budget.budgetStatus') }
  element(:on_off_campus) { |b| b.select(name: 'budget.onOffCampusFlag') }
  element(:residual_funds) { |b| b.text_field(name: 'budget.residualFunds') }
  element(:unrecovered_fa_rate_type) { |b| b.select(name: 'budget.urRateClassCode') }
  element(:f_and_a_rate_type) { |b| b.select(name: 'budget.ohRateClassCode') }
  element(:modular_budget) { |b| b.checkbox(name: 'budget.modularBudgetFlag') }
  element(:submit_cost_sharing) { |b| b.checkbox(name: 'budget.submitCostSharingFlag') }

end