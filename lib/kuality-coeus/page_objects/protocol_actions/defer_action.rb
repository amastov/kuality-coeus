class DeferAction < KCProtocol
  
  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.protocolDeferBean.comments') }
  element(:action_date) { |b| b.frm.textfield(name: 'actionHelper.protocolDeferBean.actionDate') }
  
  action(:submit) { |b| b.frm.button(name: /methodToCall\.defer/).click; b.loading }
  
end