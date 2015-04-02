class ReopenEnrollment < KCProtocol

  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.protocolReopenEnrollmentBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolReopenEnrollmentBean.actionDate') }
  action(:submit) { |b| b.frm.button(name: 'methodToCall.reopenEnrollment.anchor:ReopenEnrollment').click; b.loading }

end