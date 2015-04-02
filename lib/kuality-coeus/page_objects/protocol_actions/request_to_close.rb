class RequestToClose < KCProtocol
  
  element(:committee) { |b| b.frm.select(name: 'actionHelper.protocolCloseRequestBean.committeeId') }
  element(:reason) { |b| b.frm.textarea(name: 'actionHelper.protocolCloseRequestBean.reason') }

  action(:submit) { |b| b.frm.button(name: 'methodToCall.requestAction.taskNameprotocolRequestClose.anchor:RequestToClose') }
  
end