class MakeAdministrativeCorrection < KCProtocol

  undefine :edit

  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.protocolAdminCorrectionBean.comments') }
  
  action(:edit) { |b| b.frm.button(name: 'methodToCall.openProtocolForAdminCorrection.anchor:MakeAdministrativeCorrection').click; b.loading }
  
end