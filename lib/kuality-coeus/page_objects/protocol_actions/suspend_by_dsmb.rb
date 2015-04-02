class SuspendByDSMB < KCProtocol

  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.protocolSuspendByDsmbBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolSuspendByDsmbBean.actionDate') }
  action(:submit) { |b| b.frm.button(name: 'methodToCall.suspendByDsmb.anchor:SuspendByDSMB').click; b.loading }

end