class AddAssignedNonPersonnel < BasePage
  
  element(:category) { |b| b.select(name: 'addProjectBudgetLineItemHelper.budgetCategoryTypeCode') }
  element(:object_code_name) { |b| b.select(name: 'addProjectBudgetLineItemHelper.budgetLineItem.costElement') }
  element(:total_base_cost) { |b| b.text_field(name: 'addProjectBudgetLineItemHelper.budgetLineItem.lineItemCost') }

  action(:add_non_personnel_item) { |b| b.button(text: /Add Non-Personnel Item to/).click; b.loading }

  value(:object_code_list) { |b| b.no_frame_noko.select(name: 'addProjectBudgetLineItemHelper.budgetLineItem.costElement').options.map {|opt| opt.text }[1..-1] }

end