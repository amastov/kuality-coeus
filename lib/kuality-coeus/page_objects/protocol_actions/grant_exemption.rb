class GrantExemption < KCProtocol
  
  element(:approval_date) { |b| b.frm.text_field(name: 'actionHelper.protocolGrantExemptionBean.approvalDate') }
  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.protocolGrantExemptionBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolGrantExemptionBean.actionDate') }
  
  action(:submit) { |b| b.frm.button(name: /methodToCall\.grantExemption/).click; b.loading }
  
end