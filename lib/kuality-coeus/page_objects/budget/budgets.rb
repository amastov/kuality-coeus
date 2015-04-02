class Budgets < BasePage
  
  action(:add_budget) { |b| b.button(data_onclick: "showDialog('PropDev-BudgetPage-NewBudgetDialog');").click; b.loading }

  p_action(:open) { |name, b| b.link(text: name).click
                              b.button(text: 'Open Budget Document').when_present.click if b.body(id: 'Uif-Application').class_name=='modal-open'
                              b.loading
  }

  p_action(:include_for_submission) { |name, b| b.action_button_of(name).click; b.row_of(name).link(text: 'Include for Submission').when_present.click }

  p_element(:action_button_of) { |name, b| b.row_of(name).button }
  p_element(:row_of) { |name, b| b.tr(text: /#{name}/) }

end