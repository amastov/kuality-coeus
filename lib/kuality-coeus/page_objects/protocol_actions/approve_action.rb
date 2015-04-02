class ApproveAction < KCProtocol

  undefine :expiration_date

  element(:approval_date) { |b| b.frm.text_field(name: 'actionHelper.protocolFullApprovalBean.approvalDate') }
  element(:expiration_date) { |b| b.frm.text_field(name: 'actionHelper.protocolFullApprovalBean.expirationDate') }
  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.protocolFullApprovalBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolFullApprovalBean.actionDate') }
  
  action(:submit) { |b| b.frm.button(name: /methodToCall\.grantFullApproval\.anchor/).click; b.loading }
  
end