class ProjectIncome < BasePage

  buttons 'Add Income'

  p_element(:budget_period) { |desc, inc, b| b.target_row(desc, inc).select  }
  p_element(:description) { |desc, inc, b| b.target_row(desc, inc).textarea  }
  p_element(:project_income) { |desc, inc, b| b.target_row(desc, inc).text_field }
  p_action(:delete_income)  { |desc, inc, b| b.target_row(desc, inc).button.click; b.loading }
  
  #private

  p_element(:target_row) { |desc, inc, b| b.income_table.rows.find{ |row| row[1].textarea.value==desc && row[2].text_field.value==inc } }
  element(:income_table) { |b| b.table(class: 'table table-condensed table-bordered uif-tableCollectionLayout dataTable').tbody }

end