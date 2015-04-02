class DataAnalysisOnly < KCProtocol
  
  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.protocolPermitDataAnalysisBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolPermitDataAnalysisBean.actionDate') }
  action(:submit) { |b| b.frm.button(name: 'methodToCall.permitDataAnalysis.anchor:DataAnalysisOnly').click; b.loading }
  
end