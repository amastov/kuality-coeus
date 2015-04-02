class AdministrativelyMarkIncompleteProtocol < KCProtocol

  element(:reason) { |b| b.frm.textarea(name: 'actionHelper.protocolAdminIncompleteBean.reason') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolAdminIncompleteBean.actionDate') }
  action(:submit) { |b| b.frm.button(name: 'methodToCall.administrativelyMarkIncompleteProtocol.anchor:AdministrativelyMarkIncompleteProtocol').click; b.loading; b.awaiting_doc }

end