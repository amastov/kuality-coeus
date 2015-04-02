class IACUCModifySubmissionRequest < KCProtocol

  element(:committee) { |b| b.frm.select(name: 'actionHelper.iacucProtocolModifySubmissionBean.committeeId') }
  element(:schedule_date) { |b| b.frm.select(name: 'actionHelper.iacucProtocolModifySubmissionBean.scheduleId') }
  element(:submission_type) { |b| b.frm.select(name: 'actionHelper.iacucProtocolModifySubmissionBean.submissionTypeCode') }
  element(:submission_review_type) { |b| b.frm.select(name: 'actionHelper.iacucProtocolModifySubmissionBean.protocolReviewTypeCode') }

  element(:billable) { |b| b.frm.checkbox(name: 'actionHelper.iacucProtocolModifySubmissionBean.billable') }
  element(:type_qualifier) { |b| b.frm.select(name: 'actionHelper.iacucProtocolModifySubmissionBean.submissionQualifierTypeCode') }
  element(:determination_due_date) { |b| b.frm.text_field(name: 'actionHelper.iacucProtocolModifySubmissionBean.dueDate') }

  action(:submit) { |b| b.frm.button(name: 'methodToCall.modifySubmissionAction.anchor:ModifySubmissionRequest').click; b.loading }

end