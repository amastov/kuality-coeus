class AddIncome < BasePage

  element(:add) { |b| b.button(text: 'Add').click; b.image(alt: 'Adding Line...').wait_while_present(60) }
  
  element(:budget_period) { |b| b.select(name: "newCollectionLines['budget.budgetProjectIncomes'].budgetPeriodNumber") }
  element(:description) { |b| b.textarea(name: "newCollectionLines['budget.budgetProjectIncomes'].description") }
  element(:project_income) { |b| b.text_field(name: "newCollectionLines['budget.budgetProjectIncomes'].projectIncome") }

end