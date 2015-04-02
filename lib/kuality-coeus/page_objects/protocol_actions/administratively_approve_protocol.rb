class AdministrativelyApproveProtocol < KCProtocol
  undefine :expiration_date

  element(:approval_date) { |b| b.frm.text_field(name: 'actionHelper.protocolAdminApprovalBean.approvalDate') }
  element(:expiration_date) { |b| b.frm.text_field(name: 'actionHelper.protocolAdminApprovalBean.expirationDate') }
  element(:comments) { |b| b.frm.text_field(name: 'actionHelper.protocolAdminApprovalBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolAdminApprovalBean.actionDate') }

  element(:approve_div) { |b| b.frm.div(id: 'tab-:AdministrativelyApproveProtocol-div') }
  action(:submit) { |b| b.approve_div.button(name: /^methodToCall.grantAdminApproval.anchor/).when_present.click; b.loading; b.awaiting_doc }
end