class Budgets < BasePage
  
  action(:add_budget) { |b| b.button(data_onclick: "showDialog('PropDev-BudgetPage-NewBudgetDialog');").click; b.loading }
  
end