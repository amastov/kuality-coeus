class DeleteProtocolAmendmentOrRenewal < KCProtocol

  element(:delete_reason) { |b| b.frm.textarea(name: 'actionHelper.protocolDeleteBean.reason') }
  action(:submit) { |b| b.frm.button(name: 'methodToCall.deleteProtocol.anchor:DeleteProtocolAmendmentorRenewal').click; b.loading }

end