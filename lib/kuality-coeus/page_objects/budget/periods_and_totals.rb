class PeriodsAndTotals < BasePage

  expected_element :pttable

  document_buttons
  budget_header_elements
  new_error_messages

  buttons 'Complete Budget', 'Add Budget Period'

  value(:warnings) { |b| raise 'Fix this when https://jira.kuali.org/browse/KRAFDBCK-12072 is resolved.'  }

  p_action(:delete_period) { |period_number, b| b.button(id: "PropBudget-PeriodsPage-CollectionGroup_del_line#{period_number.to_i-1}").click; b.loading }

  value(:period_count) { |b| b.period_rows.count }

  element(:pttable) { |b| b.table(id: 'u1h1mzbd') }
  element(:period_rows) { |b| b.pttable.tbody.rows }

  # The following elements will become text fields when editing the period, so add or edit, then use these...
  p_element(:start_date_of) { |number, b| b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].startDate") }
  p_element(:end_date_of) { |number, b|  b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].endDate") }
  p_element(:cost_limit_of) { |number, b|  b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].totalCostLimit") }
  p_element(:direct_cost_limit_of) { |number, b|  b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].directCostLimit") }

  # The elements in these methods will ONLY SOMETIMES be text fields when editing. As such, they will either return the
  # Watir Text element or else a String object. Note that if it returns a String then the #value method will still work because
  # #value has been added to String. See the core_extensions.rb file.
  p_element(:total_sponsor_cost_of) { |number, b| b.tspco(number).present? ? b.tspco(number) : b.period_rows[number.to_i-1][3].text }
  p_element(:direct_cost_of) { |number, b|  b.dco(number).present? ? b.dco(number) : b.period_rows[number.to_i-1][4].text }
  p_element(:f_and_a_cost_of) { |number, b| b.fnaco(number).present? ? b.fnaco(number) : b.period_rows[number.to_i-1][5].text }
  p_element(:unrecovered_f_and_a_of) { |number, b|  b.urfnao(number).present? ? b.urfnao(number) : b.period_rows[number.to_i-1][6].text }
  p_element(:cost_sharing_of) { |number, b|  b.cso(number).present? ? b.cso(number) : b.period_rows[number.to_i-1][7].text }

  element(:submit_budget_to_sponsor) {|b| b.checkbox(name: 'submitBudgetIndicator') }
  action(:ok_complete_budget) { |b| b.button(class: 'btn btn-primary uif-action', text: 'OK').click }
  action(:cancel_complete_budget) { |b| b.button(class: 'btn btn-primary uif-action', text: 'Cancel').click }
  private

  p_element(:tspco) { |number, b| b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].totalCost") }
  p_element(:dco) { |number, b|  b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].totalDirectCost") }
  p_element(:fnaco) { |number, b|  b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].totalIndirectCost") }
  p_element(:urfnao) { |number, b|  b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].underrecoveryAmount") }
  p_element(:cso) { |number, b|  b.text_field(name:"budget.budgetPeriods\[#{number.to_i-1}\].costSharingAmount") }

end