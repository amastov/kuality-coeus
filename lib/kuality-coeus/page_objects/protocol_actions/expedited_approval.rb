class ExpeditedApproval < KCProtocol

  undefine :expiration_date

  element(:approval_date) { |b| b.frm.text_field(name: 'actionHelper.protocolExpeditedApprovalBean.approvalDate') }
  element(:expiration_date) { |b| b.frm.text_field(name: 'actionHelper.protocolExpeditedApprovalBean.expirationDate') }

  # Maybe TODO: roll these into the above methods...
  value(:approval_date_ro) { |b| b.frm.div(id: 'tab-:ExpeditedApproval-div').tr.th(text: /Approval Date:$/).parent.td.text }
  value(:expiration_date_ro) { |b| b.frm.div(id: 'tab-:ExpeditedApproval-div').tr.th(text: /Expiration Date:$/).parent.td.text }

  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.protocolExpeditedApprovalBean.comments') }
  element(:include_in_agenda) { |b| b.frm.checkbox(name: 'actionHelper.protocolExpeditedApprovalBean.assignToAgenda') }
  element(:schedule_date) { |b| b.frm.select(name: 'actionHelper.protocolExpeditedApprovalBean.scheduleId') }
  
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolExpeditedApprovalBean.actionDate') }

  element(:new_risk_level) { |b| b.frm.select(name: 'actionHelper.protocolExpeditedApprovalBean.protocolRiskLevelBean.newProtocolRiskLevel.riskLevelCode') }
  element(:new_date_assigned) { |b| b.frm.text_field(name: 'actionHelper.protocolExpeditedApprovalBean.protocolRiskLevelBean.newProtocolRiskLevel.dateAssigned') }

  action(:add_risk_level) { |b| b.frm.button(name: 'methodToCall.addRiskLevel.taskNameprotocolExpediteApproval.anchor:EnterRiskLevel').click }
  
  action(:submit) { |b| b.frm.div(id: 'tab-:ExpeditedApproval-div').button(name: /^methodToCall.grantExpeditedApproval/).click; b.loading; b.awaiting_doc }

end