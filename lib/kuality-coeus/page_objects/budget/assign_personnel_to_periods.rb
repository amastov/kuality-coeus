class AssignPersonnelToPeriods < BasePage

  document_buttons

  p_element(:period_title) { |number, b| b.h3(id: "PropBudget-AssignPersonnelToPeriodsPage-PersonnelDetails_#{number}_header").span }

  p_action(:view_period) { |number, b| b.link(text: "Period #{number}").click unless b.period_title(number).visible? }

  p_action(:assign_personnel) { |number, b| b.button(index: number.to_i-1, data_refreshid: 'PropBudget-AssignPersonnelToPeriodsPage-AddPersonnel').click
    sleep 3 #FIXME!
    b.button(data_dismissdialogid: 'PropBudget-ConfirmPeriodChangesDialog').click if number.to_i > 1
    b.loading
  }

  p_action(:details_and_rates_of) { |object_code, b| b.td(text: /#{object_code}/).link.click; b.loading }

  p_value(:requested_salary_of) { |name, b| b.visible_tab.tr(text: /#{name}/)[6].text }

  private

  element(:visible_tab) { |b| x=1; x+=1 until b.testdiv(x).visible?; b.testdiv(x) }

  p_element(:testdiv) { |x, b| b.div(id: "PropBudget-AssignPersonnelToPeriodsPage-PersonnelDetails_#{x}_tabPanel") }

end