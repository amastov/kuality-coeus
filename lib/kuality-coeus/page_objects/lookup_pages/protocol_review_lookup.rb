class ProtocolReviewLookup < Lookups

  expected_element :protocol_number

  url_info 'All%20My%20Reviews', 'kra.iacuc.onlinereview.IacucProtocolOnlineReview'

  element(:protocol_number) { |b| b.frm.text_field(name: 'lookupProtocol.protocolNumber') }

end