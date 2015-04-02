class CreateAmendment < KCProtocol

  element(:summary) { |b| b.frm.textarea(name: 'actionHelper.protocolAmendmentBean.summary') }

  # Valid parameter values for the #amend method include the following strings:
  # 'General Info', 'Funding Source', 'Protocol References and Other Identifiers', 'Protocol Organizations',
  # 'Subjects', 'Questionnaire', 'General Info', 'Areas of Research', 'Special Review', 'Protocol Personnel', 'Others'
  #
  # NOTE: 'General Info' is the title for Add/Modify Notes & Attachments
  p_element(:amend) { |title, b| b.create_amendment_div.checkbox(title: title) }

  action(:create) { |b| b.frm.button(name: 'methodToCall.createAmendment.anchor:CreateAmendment').click; b.loading; b.awaiting_doc }

  private
  
  element(:create_amendment_div) { |b| b.frm.div(id: 'tab-:CreateAmendment-div') }
  
end