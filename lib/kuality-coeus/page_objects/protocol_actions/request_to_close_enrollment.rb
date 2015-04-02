class RequestToCloseEnrollment < KCProtocol
  
  element(:committee) { |b| b.frm.select(name: 'actionHelper.protocolCloseEnrollmentRequestBean.committeeId') }
  element(:reason) { |b| b.frm.textarea(name: 'actionHelper.protocolCloseEnrollmentRequestBean.reason') }
  action(:submit) { |b| b.frm.button(name: 'methodToCall.requestAction.taskNameprotocolRequestCloseEnrollment.anchor:RequesttoCloseEnrollment').click; b.loading }
  
end