class IACUCModifySubmissionRequest < KCProtocol

  element(:committee) { |b| b.frm.select(name: 'actionHelper.iacucProtocolModifySubmissionBean.committeeId') }
  element(:schedule_date) { |b| b.frm.select(name: 'actionHelper.iacucProtocolModifySubmissionBean.scheduleId') }
  value(:schedule_date_list) { |b| b.noko.select(name: 'actionHelper.iacucProtocolModifySubmissionBean.scheduleId').options.map {|opt| opt.text }.tap(&:shift) }
  element(:submission_type) { |b| b.frm.select(name: 'actionHelper.iacucProtocolModifySubmissionBean.submissionTypeCode') }
  element(:review_type) { |b| b.frm.select(name: 'actionHelper.iacucProtocolModifySubmissionBean.protocolReviewTypeCode') }

  element(:billable) { |b| b.frm.checkbox(name: 'actionHelper.iacucProtocolModifySubmissionBean.billable') }
  element(:type_qualifier) { |b| b.frm.select(name: 'actionHelper.iacucProtocolModifySubmissionBean.submissionQualifierTypeCode') }
  element(:determination_due_date) { |b| b.frm.text_field(name: 'actionHelper.iacucProtocolModifySubmissionBean.dueDate') }

  value(:reviewers) { |b| b.msr_div.hiddens(id: /fullName$/).map { |h| h.value } }

  p_element(:reviewer_type) { |name, b| b.frm.select(name: b.noko_reviewer_select(name)) }

  action(:submit) { |b| b.frm.button(name: 'methodToCall.modifySubmissionAction.anchor:ModifySubmissionRequest').click; b.loading }

  element(:msr_div) { |b| b.frm.div(id: 'tab-:ModifySubmissionRequest-div') }
  element(:noko_msr) { |b| b.noko.div(id: 'tab-:ModifySubmissionRequest-div') }

  private

  p_element(:noko_reviewer_select) { |name, b| b.noko_msr.trs.find{ |tr| tr.tds[0].text==name }.select(name: /reviewerTypeCode/).name }

end