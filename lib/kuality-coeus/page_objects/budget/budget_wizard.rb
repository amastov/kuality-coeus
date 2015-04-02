class BudgetWizard < BasePage

  element(:name) { |b| b.text_field(name: 'addBudgetDto.budgetName') }
  p_action(:type) { |val, b| b.radio(name: 'addBudgetDto.summaryBudget', value: val).set }
  p_action(:modular) { |val, b| b.radio(name: 'addBudgetDto.modularBudget', value: val).set }
  action(:create_budget) { |b| b.button(text: 'Create Budget').click; b.loading }

end