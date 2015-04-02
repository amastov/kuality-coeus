class Expire < KCProtocol

  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.protocolExpireBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolExpireBean.actionDate') }
  action(:submit) { |b| b.frm.button(name: /^methodToCall.expire./).when_present.click; b.loading }
end