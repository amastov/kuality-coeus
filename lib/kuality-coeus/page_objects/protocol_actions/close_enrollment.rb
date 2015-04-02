class CloseEnrollment < KCProtocol
  
  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.protocolCloseEnrollmentBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolCloseEnrollmentBean.actionDate') }
  action(:submit) { |b| b.frm.button(name: 'methodToCall.closeEnrollment.anchor:CloseEnrollment').click; b.loading }
  
end