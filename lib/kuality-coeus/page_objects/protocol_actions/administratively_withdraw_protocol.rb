class AdministrativelyWithdrawProtocol < KCProtocol

  element(:reason) { |b| b.frm.textarea(name: 'actionHelper.protocolAdminWithdrawBean.reason') }
  element(:active_date) { |b| b.frm.text_field(name: 'actionHelper.protocolAdminWithdrawBean.actionDate') }
  action(:submit) { |b| b.frm.button(name: 'methodToCall.administrativelyWithdrawProtocol.anchor:AdministrativelyWithdrawProtocol').click; b.loading }

end