class NotifyCommittee < KCProtocol

  element(:committee_id) { |b| b.frm.select(name: 'actionHelper.protocolNotifyCommitteeBean.committeeId') }
  element(:comment) { |b| b.frm.textarea(id: 'actionHelper.protocolNotifyCommitteeBean.comment') }
  element(:action_date) { |b| b.frm.text_field(id: 'actionHelper.protocolNotifyCommitteeBean.actionDate') }

  action(:submit) { |b| b.frm.div(id: 'tab-:NotifyCommittee-div').button(name: 'methodToCall.notifyCommitteeProtocol.anchor:NotifyCommittee').click }

end