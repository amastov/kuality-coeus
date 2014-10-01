class BudgetWizard < BasePage

  element(:budget_name) { |b| b.text_field(name: 'addBudgetDto.budgetName') }
  action(:start_detailed_budget) { |b| b.budget_type('N') }
  action(:start_summary_budget) { |b| b.budget_type('Y') }
  action(:modular_budget) { |b| b.modular('Y') }
  action(:not_modular_budget) { |b| b.modular('N') }

  action(:create_budget) { |b| b.button(text: 'Create Budget').click; b.loading }

  private

  p_action(:budget_type) { |val, b| b.radio(name: 'addBudgetDto.summaryBudget', value: val).set }
  p_action(:modular) { |val, b| b.radio(name: 'addBudgetDto.modularBudget', value: val).set }

end