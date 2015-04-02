class Terminate < KCProtocol

  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.protocolTerminateBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolTerminateBean.actionDate') }
  action(:submit) { |b| b.frm.button(name: /^methodToCall.terminate./).when_present.click; b.loading }

end