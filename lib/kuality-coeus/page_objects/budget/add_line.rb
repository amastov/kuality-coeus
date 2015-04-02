class AddLine < Dialogs

  # Cost Sharing...
  element(:period) { |b| b.dialog_header.select(name: "newCollectionLines['budget.budgetCostShares'].projectPeriod") }
  element(:percentage) { |b| b.dialog_header.text_field(name: "newCollectionLines['budget.budgetCostShares'].sharePercentage") }

  # Unrecovered F&A...
  element(:fiscal_year) { |b| b.dialog_header.text_field(name: /fiscalYear$/) }
  element(:applicable_rate) { |b| b.dialog_header.text_field(name: /applicableRate$/) }
  element(:on_campus) { |b| b.dialog_header.select(name: /onCampusFlag$/) }
  
  # Common...
  element(:source_account) { |b| b.dialog_header.text_field(name: /sourceAccount$/) }
  element(:amount) { |b| b.dialog_header.text_field(name: /mount$/) }

  buttons 'Add', 'Cancel'

  element(:dialog_header) { |b| b.section(class: 'modal fade uif-cssGridGroup in') }

end