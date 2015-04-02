class RecordCommitteeDecision < KCProtocol
  
  element(:motion_type) { |b| b.frm.select(name: 'actionHelper.committeeDecision.motionTypeCode') }
  element(:no_count) { |b| b.frm.text_field(name: 'actionHelper.committeeDecision.noCount') }
  element(:yes_count) { |b| b.frm.text_field(name: 'actionHelper.committeeDecision.yesCount') }
  element(:voting_comments) { |b| b.frm.textarea(name: 'actionHelper.committeeDecision.votingComments') }
  element(:new_abstainer) { |b| b.frm.select(name: 'actionHelper.committeeDecision.newAbstainer.membershipId') }
  action(:add_abstainer) { |b| b.frm.button(name: /methodToCall.addAbstainer/).click; b.loading }
  element(:new_recused) { |b| b.frm.select(name: 'actionHelper.committeeDecision.newRecused.membershipId') }
  action(:add_recused) { |b| b.frm.button(name: /methodToCall.addRecused/).click; b.loading }
  
  action(:submit) { |b| b.frm.button(name: /methodToCall.submitCommitteeDecision.anchor/).click; b.loading }
  
end