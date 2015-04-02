class RequestForSuspension < KCProtocol
  
  element(:committee) { |b| b.frm.select(name: 'actionHelper.protocolSuspendRequestBean.committeeId') }
  element(:reason) { |b| b.frm.textarea(name: 'actionHelper.protocolSuspendRequestBean.reason') }
  
  action(:submit) { |b| b.frm.button(name: 'methodToCall.requestAction.taskNameprotocolRequestSuspension.anchor:RequestforSuspension').click; b.loading }
  
end