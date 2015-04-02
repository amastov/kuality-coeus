class AddPersonnelToPeriod < BasePage

  element(:dialog) { |b| b.loading; b.div(data_parent: 'PropBudget-AssignPersonnelToPeriodsPage-AddPersonnel') }
  
  element(:person) { |b| b.dialog.select(name: /personSequenceNumber/) }
  element(:object_code) { |b| b.dialog.select(name: /costElement/) }
  element(:group) { |b| b.dialog.select(name: /budgetPersonGroupName/) }
  element(:start_date) { |b| b.dialog.text_field(name: /startDate/) }
  element(:end_date) { |b| b.dialog.text_field(name: /endDate/) }
  element(:percent_effort) { |b| b.dialog.text_field(name: /percentEffort/) }
  element(:percent_charged) { |b| b.dialog.text_field(name: /percentCharged/) }
  element(:period_type) { |b| b.dialog.select(name: /periodTypeCode/) }

  action(:assign_to_period) { |b| b.div(index: 1, data_parent: 'PropBudget-AssignPersonnelToPeriodsPage-AddPersonnel').button(text: /Assign to Period/).click; b.dialog.wait_while_present; b.loading }
  
end