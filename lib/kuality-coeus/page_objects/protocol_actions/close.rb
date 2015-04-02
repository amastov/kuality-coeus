class Close < KCProtocol

  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.protocolCloseBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolCloseBean.actionDate') }

  action(:submit) { |b| b.frm.button(name: 'methodToCall.closeProtocol.anchor:Close').click; b.loading }

end