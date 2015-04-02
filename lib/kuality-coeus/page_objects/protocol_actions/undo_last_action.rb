class UndoLastAction < KCProtocol
  
  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.undoLastActionBean.comments') }

  action(:submit) { |b| b.frm.button(name: 'methodToCall.undoLastAction.anchor:UndoLastAction').click; b.loading }
  
end