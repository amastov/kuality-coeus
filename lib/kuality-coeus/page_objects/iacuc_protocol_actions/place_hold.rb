class PlaceHold < KCProtocol

  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.iacucProtocolHoldBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.iacucProtocolHoldBean.actionDate') }
  action(:submit) { |b| b.frm.button(name: /^methodToCall.iacucHold.anchor/).click; b.loading }

end