class LiftHold < KCProtocol

  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.iacucProtocolLiftHoldBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.iacucProtocolLiftHoldBean.actionDate') }
  element(:submit) { |b| b.frm.button(name: /^methodToCall.iacucLiftHold.anchor/).click; b.loading }

end