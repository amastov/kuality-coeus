class IACUCApproveAction < KCProtocol

  element(:submit) { |b| b.frm.button(name: 'methodToCall.grantFullApproval.anchor19').click; b.loading; b.awaiting_doc }

end