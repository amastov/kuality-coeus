class CreateRenewalWithoutAmendment < KCProtocol
  
  element(:summary) { |b| b.frm.textarea(name: 'actionHelper.renewalSummary') }
  
  action(:create) { |b| b.frm.button(name: 'methodToCall.createRenewal.anchor:CreateRenewalwithoutAmendment').click; b.loading }
  
end