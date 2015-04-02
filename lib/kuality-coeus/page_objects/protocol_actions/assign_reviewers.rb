class AssignReviewers < KCProtocol

  # Returns an array containing the names of the listed reviewers
  value(:reviewers) { |b| b.assign_reviewers_div.selects(title: 'Reviewer Type').map{|s| s.parent.parent.td.text} }
  p_element(:reviewer_type) { |name, b| b.assign_reviewers_div.td(text: name ).parent.select(name: /reviewerTypeCode/) }

  element(:submit_button) { |b| b.frm.button(name: 'methodToCall.assignReviewers.anchor:AssignReviewers') }
  action(:submit) { |b| b.submit_button.click; b.loading }

  private

  element(:assign_reviewers_div) { |b| b.frm.div(id: 'tab-:AssignReviewers-div') }

end