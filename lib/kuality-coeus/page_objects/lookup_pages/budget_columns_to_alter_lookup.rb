class BudgetColumnsToAlterLookup < Lookups

  url_info 'Budget%20Editable%20Columns','kra.proposaldevelopment.budget.bo.BudgetColumnsToAlter'

  element(:column_name) { |b| b.frm.select(name: 'columnName') }
  element(:lookup_argument) { |b| b.frm.select(name: 'lookupClass') }
  element(:lookup_return) { |b| b.frm.select(name: 'lookupReturn') }

end