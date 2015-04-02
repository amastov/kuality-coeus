class IACUCProtocolLookup < Lookups

  expected_element :protocol_number

  url_info 'Search Protocols', 'kra.iacuc.IacucProtocol'

  old_ui

  element(:protocol_number) { |b| b.frm.text_field(name: 'protocolNumber') }

end