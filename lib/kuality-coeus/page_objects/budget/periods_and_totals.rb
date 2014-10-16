class PeriodsAndTotals < BasePage

  document_buttons
  new_error_messages

  value(:warnings) { |b| b.div(text: 'TO DO!')  }

  action(:reset_to_period_defaults) { |b| b.button() }

  p_action(:edit_period) { |period_number, b| b.button(id: /_line#{period_number.to_i-1}$/).click; b.loading }

  value(:period_count) { |b| b.period_rows.count }

  element(:period_rows) { |b| b.div(class: 'dataTables_wrapper').tbody.rows }

  p_element(:start_date_of) { |number, b| b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].startDate") }
  p_element(:end_date_of) { |number, b|  b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].endDate") }
  p_element(:total_sponsor_cost_of) { |number, b|  b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].totalCost") }
  p_element(:direct_cost_of) { |number, b|  b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].totalDirectCost") }
  p_element(:f_and_a_cost_of) { |number, b|  b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].totalIndirectCost") }
  p_element(:unrecovered_f_and_a_of) { |number, b|  b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].underrecoveryAmount") }
  p_element(:cost_sharing_of) { |number, b|  b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].costSharingAmount") }
  p_element(:cost_limit_of) { |number, b|  b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].totalCostLimit") }
  p_element(:direct_cost_limit_of) { |number, b|  b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].directCostLimit") }

end