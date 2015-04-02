class RequestForTermination < KCProtocol

  element(:committee) { |b| b.frm.select(name: 'actionHelper.protocolTerminateRequestBean.committeeId') }
  element(:reason) { |b| b.frm.textarea(name: 'actionHelper.protocolTerminateRequestBean.reason') }

  action(:submit) { |b| b.frm.button(name: 'methodToCall.requestAction.taskNameprotocolRequestTerminate.anchor:RequestforTermination').click; b.loading }

end