class NonPersonnelCosts < BasePage

  budget_header_elements
  buttons 'Save and Continue', 'Complete Budget'

  # FIXME...
  action(:save) { |b| b.button(id: 'u1agxtwx').click; b.loading }

  p_element(:period_title) { |number, b| b.h3(id: "PropBudget-NonPersonnelCosts-LineItemDetails_#{number}_header").span }

  p_action(:view_period) { |number, b| b.link(text: "Period #{number}").click unless b.period_title(number).visible?; b.loading }

  action(:assign_non_personnel) { |b| b.active_tab.button(text: 'Assign Non-Personnel...').click; b.loading }

  p_action(:details_of) { |description, b| b.items_rows.find{ |item| item[0].text==description }.button.click; b.loading }

  action(:edit_participant_count) { |b| b.td(text: /Participant Support/).link(text: 'edit').click; b.loading }

  p_action(:trash) { |description, b| b.items_rows.find{ |item| item[0].text==description }.button(id: /PropBudget-NonPersonnelCosts-LineItemDetails_\d+_del_line\d+/).click; b.loading }

  p_value(:exist?) { |description, b|
    begin
      !b.items_rows.find{ |item| item[0].text==description }.nil?
    rescue Watir::Exception::UnknownObjectException
      false
    end
  }

  private

  element(:items_rows) { |b| b.active_tab.tbody.trs.find_all{ |tr| tr.id==''} }
  element(:active_tab) { |b| b.div(class: 'tab-pane active') }

  element(:title) { |b| b.h3(id: 'PropBudget-NonPersonnelCosts-TabGroup_header') }

end