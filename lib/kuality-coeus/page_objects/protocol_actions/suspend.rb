class Suspend < KCProtocol

  element(:suspend_div) { |b| b.frm.div(id: 'tab-:Suspend-div') }
  action(:submit) {|b| b.frm.button(name: /^methodToCall.suspend./).click; b.loading }
  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.protocolSuspendBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolSuspendBean.actionDate') }

end