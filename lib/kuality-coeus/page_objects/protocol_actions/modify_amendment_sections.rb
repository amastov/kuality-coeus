class ModifyAmendmentSections < KCProtocol

  element(:amendment_summary) { |b| b.modify_amendment_div.textarea(name: 'actionHelper.protocolAmendmentBean.summary') }

  # Valid parameter values for the #amend method include the following strings:
  # 'General Info', 'Funding Source', 'Protocol References and Other Identifiers', 'Protocol Organizations',
  # 'Subjects', 'Questionnaire', 'General Info', 'Areas of Research', 'Special Review', 'Protocol Personnel', 'Others'
  #
  # NOTE: 'General Info' is the title for Add/Modify Notes & Attachments
  p_element(:amend) { |title, b| b.modify_amendment_div.checkbox(title: title) }

  action(:update) { |b| b.frm.button(name: 'methodToCall.modifyAmendmentSections.anchor:ModifyAmendmentSections').click }

  private

  element(:modify_amendment_div) { |b| b.frm.div(id: 'tab-:ModifyAmendmentSections-div') }

end