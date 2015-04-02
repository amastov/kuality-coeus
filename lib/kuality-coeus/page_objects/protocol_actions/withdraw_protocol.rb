class  WithdrawProtocol < KCProtocol

  element(:withdrawal_reason) { |b| b.frm.textarea(name: 'actionHelper.protocolWithdrawBean.reason') }
  action(:submit) { |b| b.frm.button(name: 'methodToCall.withdrawProtocol.anchor:WithdrawProtocol').click; b.loading }

end