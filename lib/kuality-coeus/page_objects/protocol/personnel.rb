class ProtocolPersonnel < KCProtocol

  element(:protocol_role) { |b| b.frm.select(name: 'personnelHelper.newProtocolPerson.protocolPersonRoleId') }
  action(:employee_search) { |b| b.frm.button(name: /KcPerson/).click }
  action(:non_employee_search) { |b| b.frm.button(name: /NonOrganizationalRolodex/).click }
  action(:add_person) { |b| b.frm.button(name: 'methodToCall.addProtocolPerson').click; b.loading }

  value(:added_people) { |b| b.noko.div(id: 'workarea').h3s.map{ |h| onespace(h.span(class: 'subhead-left').text) }.delete_if{ |i| i=='Attachments'} }

end