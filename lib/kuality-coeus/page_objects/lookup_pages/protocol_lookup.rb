class ProtocolLookup < Lookups

  expected_element :protocol_number

  url_info 'Protocols', 'kra.irb.Protocol'

  old_ui

  element(:protocol_number) { |b| b.frm.text_field(name: 'protocolNumber') }

  element(:active_yes) { |b| b.frm.radio(name: 'active', value: 'Y') }
  element(:active_no) { |b| b.frm.radio(name: 'active', value: 'N') }
  element(:active_both) { |b| b.frm.radio(name: 'active', title: "Active - Both") }
end