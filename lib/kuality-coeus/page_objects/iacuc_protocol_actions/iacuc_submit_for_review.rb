class IACUCSubmitForReview < KCProtocol

  element(:submission_type) { |b| b.frm.select(name: 'actionHelper.iacucProtocolSubmitAction.submissionTypeCode') }
  element(:review_type) { |b| b.frm.select(name: 'actionHelper.iacucProtocolSubmitAction.protocolReviewTypeCode') }
  element(:type_qualifier) { |b| b.frm.select(name: 'actionHelper.iacucProtocolSubmitAction.submissionQualifierTypeCode') }
  action(:submit) { |b| b.frm.button(name: 'methodToCall.submitForReview.anchor:SubmitforReview').click; b.loading; b.awaiting_doc }

end