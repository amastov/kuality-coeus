class RequestForDataAnalysisOnly < KCProtocol

  element(:committee) { |b| b.frm.select(name: 'actionHelper.protocolDataAnalysisRequestBean.committeeId') }
  element(:reason) { |b| b.frm.textarea(name: 'actionHelper.protocolDataAnalysisRequestBean.reason') }
  action(:submit) { |b| b.frm.button(name: 'methodToCall.requestAction.taskNameprotocolRequestDataAnalysis.anchor:RequestforDataAnalysisOnly').click; b.loading }

end