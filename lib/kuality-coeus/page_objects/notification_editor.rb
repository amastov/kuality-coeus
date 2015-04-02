# This is pre-6.0 UI. Needs to be removed when the 5.x UI is replaced.
# See the modal_dialogs.rb file for the new Notification Editor definitions.
class NotificationEditor < BasePage

  global_buttons
  document_header_elements

  undefine :send_notification

  action(:send_notification) { |b| b.frm.button(name: 'methodToCall.sendNotification').click }

  action(:employee_search) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.kra.bo.KcPerson!!).(((personId:notificationHelper.newPersonId))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchor').click }
  
  action(:add) { |b| b.frm.button(name: 'methodToCall.addNotificationRecipient.anchor').click }

  element(:subject) { |b| b.frm.text_field(name: 'notificationHelper.notification.subject') }
  element(:message) { |b| b.frm.textarea(name: 'notificationHelper.notification.message') }

  # Unfortunately this is necessary because it's the only way
  # to know the IP Number when it gets created
  value(:institutional_proposal_number) { |b| b.message.text[/(?<=is )\d+/] }

  element(:notification_editor_div) { |b| b.frm.div(id: 'tab-NotificationEditor-div') }

end