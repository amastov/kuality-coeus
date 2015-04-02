class NotifyIRB < KCProtocol

  element(:submission_type_qualifier) { |b| b.frm.select(name: 'actionHelper.protocolNotifyIrbBean.submissionQualifierTypeCode') }
  element(:submission_review_type) { |b| b.frm.select(name: 'actionHelper.protocolNotifyIrbBean.reviewTypeCode') }
  element(:committee) { |b| b.frm.select(name: 'actionHelper.protocolNotifyIrbBean.committeeId') }
  
  action(:submit) { |b| b.frm.button(name: 'methodToCall.notifyIrbProtocol.anchor:NotifyIRB').click; b.loading }

end