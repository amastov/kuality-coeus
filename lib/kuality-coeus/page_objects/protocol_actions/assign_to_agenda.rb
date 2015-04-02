class AssignToAgenda < KCProtocol

  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.assignToAgendaBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.assignToAgendaBean.actionDate') }

  element(:new_risk_level) { |b| b.frm.select(name: 'actionHelper.protocolFullApprovalBean.protocolRiskLevelBean.newProtocolRiskLevel.riskLevelCode') }
  element(:new_date_assigned) { |b| b.frm.text_field(name: 'actionHelper.protocolFullApprovalBean.protocolRiskLevelBean.newProtocolRiskLevel.dateAssigned') }
  action(:add_risk_level) { |b| b.frm.button(name: 'methodToCall.addRiskLevel.taskNameprotocolApprove.anchor:EnterRiskLevel').click; b.loading }

  #TODO: 1) Write a method for putting existing risk levels into a Hash. 2) Write a delete method

  action(:submit) { |b| b.frm.button(name: /methodToCall\.assignToAgenda/).click; b.loading }
  
end